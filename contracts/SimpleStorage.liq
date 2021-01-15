// https://claudebarde.medium.com/getting-started-with-liquidity-37660da4390

[%%version 2.0]

type storage = int;

let%init storage = 0;

let%entry increment = (num: int, storage) => ([], storage + num);