// 1. Add this block at the VERY TOP of the file
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Match this to your Flutter version's requirements
        classpath("com.android.tools.build:gradle:8.7.3")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    val newBuildDir = rootProject.layout.buildDirectory.dir(project.name)
    project.layout.buildDirectory.set(newBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}