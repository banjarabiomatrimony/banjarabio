buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Provide Android Gradle Plugin classpath for plugins using old apply plugin syntax
        // Match the version used by connectivity_plus and other plugins
        classpath("com.android.tools.build:gradle:8.12.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory   
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
