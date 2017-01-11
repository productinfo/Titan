# Titan

A microframework for writing Swift web apps and container-based web services.

## Motivation

The current landscape of Swift web frameworks is vertically integrated. These frameworks are unsuitable for specific microservice environments where very small codebases are the overriding concern. Additionally, they do not or just barely support modularized middleware and make it generally very hard to write, add, re-use and share middleware with the open-source community. 

## What

Titan is an HTTP router with middleware support. It draws heavily on existing codebases to reduce the risk in a production environment.

Titan helps you write functions that receive an HTTP request and produce an HTTP response. It is compatible with Nest and Kitura's `ServerDelegate` protocol. It is optimized for clarity and developer productivity over speed.

Titan is not a web server, and it has very few features. It was architected in one evening at a bar in Germany. It is therefore very well-engineered.

## Examples

...can be found in the `examples` directory.

## Contributing

Titan is maintained by Thomas Catterall ([@swizzlr](https://github.com/swizzlr)), Johannes Erhardt ([@johanneserhardt](https://github.com/johanneserhardt)), Sebastian Kreutzberger ([@skreutzberger](https://github.com/skreutzberger)) and Gabriel Peart ([@gabrielPeart](https://github.com/gabrielPeart)).

Contributions are more than welcomed. You can either work on existing Github issues or discuss with us your ideas in a new Github issue. Thanks 🙌

## Background and License

Titan was initially developed for a project run by the [Bermuda Digital Studio (BDS)](www.bdstudio.de). The BDS is a team devoted to enable great digital product management for the retail business of [innogy SE's](www.innogy.com). 

Titan Framework is released under the [Apache 2.0 License](https://github.com/bermudadigitalstudio/titan/blob/master/LICENSE.txt).
