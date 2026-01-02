allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://maven.myket.ir") }
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
    
    // Override buildscript برای همه پلاگین‌های Flutter قبل از evaluation
    if (project.name != "app") {
        project.buildscript {
            repositories {
                google()
                mavenCentral()
                maven { url = uri("https://maven.myket.ir") }
            }
            dependencies {
                // Force استفاده از نسخه سازگار با Gradle 8
                classpath("com.android.tools.build:gradle:8.11.1")
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
