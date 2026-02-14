package com.example.hellomultiplatform

class Greeting {
    private val platform = getPlatform()

    fun greet(): String {
        return "Hello, World! Running on ${platform.name}"
    }
}
