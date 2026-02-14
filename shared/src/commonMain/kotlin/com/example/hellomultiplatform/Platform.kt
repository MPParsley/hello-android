package com.example.hellomultiplatform

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform
