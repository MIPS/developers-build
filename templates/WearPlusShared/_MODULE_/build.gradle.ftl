<#--
 Copyright 2014 The Android Open Source Project

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
buildscript {
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:0.12.+'
    }
}

apply plugin: 'com.android.application'

<#if sample.repository?has_content>
repositories {
<#list sample.repository as rep>
    ${rep}
</#list>
}
</#if>

dependencies {

<#list sample.dependency as dep>
    compile "${dep}"
</#list>
<#list sample.dependency_external as dep>
    compile files(${dep})
</#list>

    compile ${play_services_dependency}
    compile ${android_support_v13_dependency}
    compile project(':Shared')
    wearApp project(':Wearable')
}

// The sample build uses multiple directories to
// keep boilerplate and common code separate from
// the main sample code.
List<String> dirs = [
    'main',     // main sample code; look here for the interesting stuff.
    'common',   // components that are reused by multiple samples
    'template'] // boilerplate code that is generated by the sample template process

android {
    compileSdkVersion ${compile_sdk}

    buildToolsVersion ${build_tools_version}

    defaultConfig {
        minSdkVersion ${min_sdk}
        targetSdkVersion ${compile_sdk}
    }

    sourceSets {
        main {
            dirs.each { dir ->
<#noparse>
                java.srcDirs "src/${dir}/java"
                res.srcDirs "src/${dir}/res"
</#noparse>
            }
        }
        androidTest.setRoot('tests')
        androidTest.java.srcDirs = ['tests/src']

<#if sample.defaultConfig?has_content>
        defaultConfig {
        ${sample.defaultConfig}
        }
<#else>
</#if>
    }

}
// BEGIN_EXCLUDE
// Tasks below this line will be hidden from release output

task preflight (dependsOn: parent.preflight) {
    project.afterEvaluate {
        // Inject a preflight task into each variant so we have a place to hook tasks
        // that need to run before any of the android build tasks.
        //
        android.applicationVariants.each { variant ->
        <#noparse>
            tasks.getByPath("prepare${variant.name.capitalize()}Dependencies").dependsOn preflight
        </#noparse>
        }
    }
}

// END_EXCLUDE
