# Bürokratt Architecture Design Records

> _In process_

Intended targets of this document are IT architects and developers involved with the developments of Bürokratt.

This document _will contain_ history of all architectural design decisions, covering both approved and disapproved choices with explanations.

## Authentication

### TIM

For TARA-based authentication (see [GitHub repo](https://e-gov.github.io/TARA-Doku/) and [general information](https://www.ria.ee/en/state-information-system/eid/partners.html)), Bürokratt's custom component [TIM (TARA Integration Module)](https://github.com/buerokratt/TIM) is used.

## REST services

### Function as a Service (FaaS)

Custom functions that have potential to be used in more than one service, must be provided in a form of Function as a Service (FaaS).

By FaaS we understand REST-based requests serving just one specific function.

For Bürokratt, by default, FaaS is provided as a [Ruuter](https://github.com/buerokratt/Ruuter) REST endpoint.


## Push technologies

### Server-sent events instead of WebSockets

Server-sent events have been chosen over [WebSockets](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API) due to preferring unidirectional communication instead of bidirectional one until using just text-based communication.

https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events

## Translations

All translations within GUI (graphical user interface) must be [i18n-compatible](https://www.i18next.com/).
