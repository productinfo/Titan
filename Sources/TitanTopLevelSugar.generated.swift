// Top level versions of Titan instance methods.

// These provide a syntactic sugar by referring to an internally declared global instance of Titan, allowing you to write very simple main files (see `README.md`)

// These methods are automatically generated by Sourcery, and can be found in the Templates/ folder.

public func get(_ path: String, _ handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.get(path, handler)
}

public func post(_ path: String, _ handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.post(path, handler)
}

public func put(_ path: String, _ handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.put(path, handler)
}

public func patch(_ path: String, _ handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.patch(path, handler)
}

public func delete(_ path: String, _ handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.delete(path, handler)
}

public func options(_ path: String, _ handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.options(path, handler)
}

public func head(_ path: String, _ handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.head(path, handler)
}

public func route(_ path: String, _ handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.route(path, handler)
}

public func get(path: String, handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.get(path: path, handler: handler)
}

public func post(path: String, handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.post(path: path, handler: handler)
}

public func put(path: String, handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.put(path: path, handler: handler)
}

public func patch(path: String, handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.patch(path: path, handler: handler)
}

public func delete(path: String, handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.delete(path: path, handler: handler)
}

public func options(path: String, handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.options(path: path, handler: handler)
}

public func head(path: String, handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.head(path: path, handler: handler)
}

public func route(method: String?, path: String, handler: @escaping Middleware) {
  GlobalDefaultTitanInstance.route(method: method, path: path, handler: handler)
}

