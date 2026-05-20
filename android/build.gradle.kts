// Ficheiro: android/build.gradle.kts
import org.gradle.api.Action
import org.gradle.api.Project

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// --- CORREÇÃO DE ARQUITETURA: SAFE INJECTION BUG (AGP 8+ / API 36) ---
subprojects {
    val proj = this
    
    // Encapsular a lógica numa Action reutilizável para a podermos executar 
    // no timing exato permitido pelo ciclo de vida do Gradle.
    val fixAndroidAction = Action<Project> {
        val androidExt = this.extensions.findByName("android")
        if (androidExt != null) {
            // 1. Forçar CompileSDK 36
            try {
                val setCompileSdk = androidExt.javaClass.getMethod("setCompileSdk", Int::class.java)
                setCompileSdk.invoke(androidExt, 36)
            } catch (e: Exception) {
                try {
                    val setCompileSdkVersion = androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.java)
                    setCompileSdkVersion.invoke(androidExt, 36)
                } catch (e2: Exception) {}
            }

            // 2. Preencher Namespace obsoleto extraindo do AndroidManifest.xml
            try {
                val getNamespace = androidExt.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(androidExt) == null) {
                    var fallbackNamespace = "com.legacy.plugin.${this.name.replace("-", "_")}"
                    val manifestFile = this.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val match = Regex("""package="([^"]+)"""").find(manifestFile.readText())
                        if (match != null) {
                            fallbackNamespace = match.groupValues[1]
                        }
                    }
                    val setNamespace = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(androidExt, fallbackNamespace)
                }
            } catch (e: Exception) {}
        }
    }

    // Condição crítica: Evita a exceção "Cannot run Project.afterEvaluate(Action) when the project is already evaluated".
    // Devido à árvore de dependências do Flutter (evaluationDependsOn), alguns subprojetos 
    // já vêm avaliados. Aqui injetamos diretamente se já estiver pronto, ou agendamos se não estiver.
    if (proj.state.executed) {
        fixAndroidAction.execute(proj)
    } else {
        proj.afterEvaluate(fixAndroidAction)
    }
}
// -----------------------------------------------------------------------------------------

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}