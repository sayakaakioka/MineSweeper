# マインスイーパー

## ここに置かれているのは…

Processing で書かれたマインスイーパーのサンプルプログラムです。
人間が遊ぶときには、Sweeper タブの中の`draw()`のうち、
`decide()`の行と`delay(1000)`の行をコメントアウトしてください。

```java
void draw() {
  // どのマスを開けるかを決定する。
  // 人間が遊びたい時にはコメントアウトする。
  decide();

  // 盤面に応じて描画。ゲームオーバーならば全てオープンにして描画。
  mineSweeper.update();

  // ゲームクリア済みなので以降ループは回さない。
  if (mineSweeper.isGameCleared()) {
    noLoop();
  }

  // ゲームオーバーなので以降ループは回さない。
  if (mineSweeper.isGameOver()) {
    noLoop();
  }

  // オートプレイの場合、様子を見やすいように1秒停止。
  // 人間が遊びたい時にはコメントアウトする。
  delay(1000);
}
```

## ルール

全ての空きマスを開けることができたらゲームクリア、
爆弾をクリックしてしまったらゲームオーバーです。

左クリックで指定したマスを開ける、右クリックで旗を立てる設定になっています。
既に旗が立っているところは、左クリックしても開きません。
また、既に旗が立っているところを右クリックすると、旗が外れます。

## オートプレイを作るには…

Sweeper タブの中の`decide()`をいじりましょう
（上で`decide()`や`delay(1000)`をコメントアウトした場合には、
元に戻すのを忘れずに！）。
サンプルはデタラメな動きになっているので、ぜひ工夫して賢くしてください。

```java
// オートプレイの挙動を決める。
void decide() {
  // 操作するマスをランダムに決定。
  int randomR = int(random(0, rows));
  int randomC = int(random(0, columns));

  // 指定したマスが開いているか、旗が立っている限り回るループ。
  do {
    randomR = int(random(0, rows));
    randomC = int(random(0, columns));
  } while (mineSweeper.isOpen(randomR, randomC) || mineSweeper.isMarked(randomR, randomC));

  if (mineSweeper.leftOpen() > (rows*columns-bombs)*0.9) {
    // 空きマス全体のうち9割以上が開いていなければ、指定したマスを開ける。
    mineSweeper.openByIndex(randomR, randomC);
  } else {
    if(mineSweeper.marked() > rows*columns-mineSweeper.leftOpen()-bombs){
      // 開けた数よりも旗の数が多ければ開ける。
      mineSweeper.openByIndex(randomR, randomC);
    } else{
      // 旗の数の方が少なければ旗を立てる。
      mineSweeper.markByIndex(randomR, randomC);
    }
  }

  // デバッグ用
  println("開けた数: " + (rows*columns-mineSweeper.leftOpen()-bombs)
          + ", 旗の数: " + mineSweeper.marked()
          + ", 爆弾の数: " + bombs
          + ", 残りの空きマス数: " + mineSweeper.leftOpen());
}
```

## ゲームの状況を知るための関数

ゲームの状況を知るための関数や変数をいくつか用意しました。
不足しているものがあれば、リクエストしてください。
使い方については、上の`decide()`の中身も参考にしてください。
各マスの状態は、配列に保存されています。
左上が`(0, 0)`、右下が`(rows-1, columns-1)`です。

- `rows`: 碁盤の目のように並べられたマスの縦方向の数です。
- `columns`: 碁盤の目のように並べられたマスの横方向の数です。
- `bombs`: 爆弾の総数です。
- `mineSweeper.isGameCleared()`: ゲームがクリア済ならば`true`、それ以外で`false`を返します。
- `mineSweeper.isGameOver()`: ゲームオーバーしていたら`true`、それ以外では`false`を返します。
- `mineSweeper.isMarked(r, c)`: 上から`r`番目、左から`c`番目のマスに旗が立っていれば`true`、それ以外では`false`を返します。`r`や`c`は`0`から始まることに注意。
- `mineSweeper.isOpen(r, c)`: 上から`r`番目、左から`c`番目のマスが開いていれば`true`、それ以外では`false`を返します。`r`や`c`は`0`から始まることに注意。
- `mineSweeper.leftOpen()`: まだ開いていない空きマスの数を返します。
- `mineSweeper.markByIndex(r, c)`: 上から`r`番目、左から`c`番目のマスに旗を立てます。既に旗が立っている場合には、旗を外します。`r`や`c`は`0`から始まることに注意。
- `mineSweeper.marked()`: 立てた旗の数を返します。
- `mineSweeper.openByIndex(r, c)`: 上から`r`番目、左から`c`番目のマスを開けます。既に旗が立っている場合には、開けられません。`r`や`c`は`0`から始まることに注意。
