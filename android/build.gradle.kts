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

// اضافه کردن namespace برای flutter_midi و سایر پکیج‌های Flutter
subprojects {
    afterEvaluate {
        if (project.name != "app") {
            try {
                val android = project.extensions.findByName("android")
                if (android != null) {
                    // استفاده از reflection برای تنظیم namespace
                    val namespaceField = try {
                        android::class.java.getDeclaredField("namespace")
                    } catch (e: NoSuchFieldException) {
                        null
                    }
                    
                    if (namespaceField != null) {
                        namespaceField.isAccessible = true
                        val currentNamespace = namespaceField.get(android) as? String
                        
                        if (currentNamespace.isNullOrEmpty()) {
                            // استخراج از AndroidManifest
                            val manifestFile = project.file("src/main/AndroidManifest.xml")
                            val packageName = if (manifestFile.exists()) {
                                val manifestContent = manifestFile.readText()
                                val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestContent)
                                packageMatch?.groupValues?.get(1)
                            } else null
                            
                            val finalNamespace = packageName ?: if (project.name == "flutter_midi") {
                                "com.example.flutter_midi"
                            } else null
                            
                            if (finalNamespace != null) {
                                namespaceField.set(android, finalNamespace)
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // خطا نادیده گرفته می‌شود - ممکن است namespace از قبل تنظیم شده باشد
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
