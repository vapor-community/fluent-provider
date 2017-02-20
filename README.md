# Fluent Provider for Vapor

![Swift](http://img.shields.io/badge/swift-3.1-brightgreen.svg)
[![CircleCI](https://circleci.com/gh/vapor/fluent-provider.svg?style=shield)](https://circleci.com/gh/vapor/fluent-provider)
[![Slack Status](http://vapor.team/badge.svg)](http://vapor.team)

Adds Fluent ORM to the Vapor web framework.

## Add the dependency to Package.swift

```JSON
.Package(url: "https://github.com/vapor/fluent-provider.git", ...)
```

## Add the provider to your Droplet instance

```swift
import Vapor
import VaporFluent

let drop = Droplet()
try drop.addProvider(VaporFluent.Provider.self)
```
