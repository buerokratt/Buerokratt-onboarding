# Bürokratt Architecture Design Records

> _In process_

The intended targets of this document are IT architects and developers involved with the developments of Bürokratt.

This document _will contain_ history of all architectural design decisions, covering both approved and disapproved choices with explanations.

## Push technologies

### Server-sent events instead of WebSockets

Server-sent events have been chosen over [WebSockets](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API) due to preferring unidirectional communication instead of bidirectional one.

https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events
