# Decorators
Decorators are nodes that can be used in combination with any other node described in the manual

## Failer
A failer node will always return a `FAILURE` status code.

## Succeeder
A succeeder node will always return a `SUCCESS` status code.

## Inverter
A inverter will return `FAILURE` in case its child returns a `SUCCESS` status code or `SUCCESS` in case its child returns a `FAILURE` status code.

## Limiter
The limiter will execute its child x amount of times. When the number of maximum ticks is reached, it will return a `FAILURE` status code.
