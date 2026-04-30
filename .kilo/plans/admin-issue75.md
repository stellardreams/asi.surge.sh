#### 2.a Decision Time: 2029-04-29 20:30 Eastern / 2029-04-30 00:30 UTC
**[decision]('https://www.youtube.com/shorts/bU-pwPhbOTw?reload=9')**: Plans will live in `'plans'` (root) vs `'.kilo/plans/'` as the canonical location.

```mermaid
flowchart TD
    decision[decision] --> |'plans'|
    decision --> |'.kilo/plans/'|
```