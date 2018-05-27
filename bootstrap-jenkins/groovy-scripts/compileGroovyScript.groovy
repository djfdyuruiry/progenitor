#!/usr/bin/env groovy
import groovy.json.JsonSlurper
import groovy.text.SimpleTemplateEngine

final jsonSlurper = new JsonSlurper()
final engine = new SimpleTemplateEngine()

if (args.length < 2) {
    System.err.println "Usage: compileGroovyScript.groovy pathToTemplateScript templateBindingsJson"
    return
}

def scriptPath = args[0]
def bindingJson = args[1]

println "Script Path: $scriptPath"
println "Binding Json: $bindingJson"

def templateText = new File(scriptPath).text
def binding = jsonSlurper.parseText(bindingJson)

def template = engine.createTemplate(templateText).make(binding)

println template.toString()
