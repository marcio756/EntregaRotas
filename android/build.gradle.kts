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

// --- CORREÇÃO DE ARQUITETURA: PATCH REATIVO PARA NAMESPACES (AGP 8.0+ / KOTLIN DSL) ---
// Utiliza um hook reativo em vez de afterEvaluate para evitar o erro "already evaluated".
subprojects {
    val proj = this
    proj.plugins.withId("com.android.library") {
        val androidExt = proj.extensions.findByName("android")
        if (androidExt != null) {
            try {
                val getNamespaceMethod = androidExt.javaClass.getMethod("getNamespace")
                if (getNamespaceMethod.invoke(androidExt) == null) {
                    val setNamespaceMethod = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespaceMethod.invoke(androidExt, proj.group.toString())
                }
            } catch (e: Exception) {
                // Fallback silencioso
            }
        }
    }
}
// -----------------------------------------------------------------------------------------

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}