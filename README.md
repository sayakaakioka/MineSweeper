# マインスイーパー

## ここに置かれているのは…

Processing で書かれたマインスイーパーのサンプルプログラムです。
人間が遊ぶときには、Sweeper タブの中の`draw()`のうち、
冒頭の部分をコメントアウトしてください。

```java
void draw() {
  // 前回の処理から1秒以上経っていたら、どのマスを開けるかを決定する。
  // 人間が遊びたい時にはコメントアウトする。
  if(millis()-startTime>=1000){
    decide();
    startTime = millis();
  }
  
  // 盤面に応じて描画。ゲームオーバーならば全てオープンにして描画。
  drawer.update();

  // ゲームクリア済みなので以降ループは回さない。
  if (mineSweeper.isGameCleared()) {
    noLoop();
  }

  // ゲームオーバーなので以降ループは回さない。
  if (mineSweeper.isGameOver()) {
    noLoop();
  }
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
（上でオートプレイ用のコードをコメントアウトした場合には、
元に戻すのを忘れずに！）。
サンプルはデタラメな動きになっているので、ぜひ工夫して賢くしてください。

サンプルは、まず最初に、前回開けたマスの周辺に、爆弾が2つ以下のマスがあれば、そこを開けます。
該当するマスがなければ、まだ開いておらず、旗も立っていないマスを、ランダムにひとつ選びます。
このマスを開けるのは、全体の空きマスのうち9割以上が開いていないとき、もしくは、開けたマスの数よりも
旗を立てたマスの数が多い場合です。
それ以外の場合には、旗を立てます。

```java
// オートプレイの挙動を決める。
void decide() {
  // 先ほど開けたマスの周囲8マスの爆弾の数が3未満ならば
  // 近隣のマスを開ける
  if (lastClickedR != -1 && lastClickedC != -1 && mineSweeper.neighbors(lastClickedR, lastClickedC).id() < 3) {
    if (lastClickedR-1>=0 && !mineSweeper.isOpen(lastClickedR-1, lastClickedC)) {
      // 上が開けられるので上を開ける
      lastClickedR--;
      mineSweeper.open(lastClickedR, lastClickedC);
      return;
    } else if (lastClickedR+1<ROWS && !mineSweeper.isOpen(lastClickedR+1, lastClickedC)) {
      // 下が開けられるので下を開ける
      lastClickedR++;
      mineSweeper.open(lastClickedR, lastClickedC);
      return;
    } else if (lastClickedC-1>=0 && !mineSweeper.isOpen(lastClickedR, lastClickedC-1)) {
      // 左が開けられるので左を開ける
      lastClickedC--;
      mineSweeper.open(lastClickedR, lastClickedC);
      return;
    } else if (lastClickedC+1<COLUMNS && !mineSweeper.isOpen(lastClickedR, lastClickedC+1)) {
      // 右が開けられるので右を開ける
      lastClickedC++;
      mineSweeper.open(lastClickedR, lastClickedC);
      return;
    }
    // 近隣に開けられるマスがなかったので以下でランダムに開ける
  }

  // 操作するマスをランダムに決定。
  int randomR = int(random(0, ROWS));
  int randomC = int(random(0, COLUMNS));

  // 指定したマスが開いているか、旗が立っている限り回るループ。
  do {
    randomR = int(random(0, ROWS));
    randomC = int(random(0, COLUMNS));
  } while (mineSweeper.isOpen(randomR, randomC) || mineSweeper.isMarked(randomR, randomC));

  if (mineSweeper.leftOpen() > (ROWS*COLUMNS-BOMBS)*0.9) {
    // 空きマス全体のうち9割以上が開いていなければ、指定したマスを開ける。
    mineSweeper.open(randomR, randomC);
  } else {
    if (mineSweeper.marked() > ROWS*COLUMNS-mineSweeper.leftOpen()-BOMBS) {
      // 開けた数よりも旗の数が多ければ開ける。
      mineSweeper.open(randomR, randomC);
    } else {
      // 旗の数の方が少なければ旗を立てる。
      mineSweeper.mark(randomR, randomC);
    }
  }

  // 最後にクリックしたマス情報を更新
  lastClickedR = randomR;
  lastClickedC = randomC;

  // デバッグ用
  println("開けた数: " + (ROWS*COLUMNS-mineSweeper.leftOpen()-BOMBS)
    + ", 旗の数: " + mineSweeper.marked()
    + ", 爆弾の数: " + BOMBS
    + ", 残りの空きマス数: " + mineSweeper.leftOpen());
}
```

## ゲームの状況を知るための関数

ゲームの状況を知るための関数や変数をいくつか用意しました。
不足しているものがあれば、リクエストしてください。
使い方については、上の`decide()`の中身も参考にしてください。
各マスの状態は、配列に保存されています。
左上が`(0, 0)`、右下が`(ROWS-1, COLUMNS-1)`です。

- `ROWS`: 碁盤の目のように並べられたマスの縦方向の数です。
- `COLUMNS`: 碁盤の目のように並べられたマスの横方向の数です。
- `BOMBS`: 爆弾の総数です。
- `mineSweeper.isGameCleared()`: ゲームがクリア済ならば`true`、それ以外で`false`を返します。
- `mineSweeper.isGameOver()`: ゲームオーバーしていたら`true`、それ以外では`false`を返します。
- `mineSweeper.isLastClicked(r, c)`: 上から`r`番目、左から`c`番目のマスが前回クリックしたマスならば`true`、それ以外では`false`を返します。
- `mineSweeper.isMarked(r, c)`: 上から`r`番目、左から`c`番目のマスに旗が立っていれば`true`、それ以外では`false`を返します。`r`や`c`は`0`から始まることに注意。
- `mineSweeper.isOpen(r, c)`: 上から`r`番目、左から`c`番目のマスが開いていれば`true`、それ以外では`false`を返します。`r`や`c`は`0`から始まることに注意。
- `mineSweeper.leftOpen()`: まだ開いていない空きマスの数を返します。
- `mineSweeper.mark(r, c)`: 上から`r`番目、左から`c`番目のマスに旗を立てます。既に旗が立っている場合には、旗を外します。`r`や`c`は`0`から始まることに注意。
- `mineSweeper.marked()`: 立てた旗の数を返します。
- `mineSweeper.neighbors(r, c)`: 上から`r`番目、左から`c`番目のマスについて、周囲8マスの爆弾の数についての情報を返します。詳しくは`BombInfo`のタブや、`MineSweeper`タブの中での使いかた、`Sweeper`タブの`decide()`での使いかたなどを見てください。爆弾の状態を数字（多くの場合は爆弾の数ですが、異なる場合もあるので注意）で取得したい場合には、`mineSweeper.neighbors(r, c).id()`のようにしてください。
- `mineSweeper.open(r, c)`: 上から`r`番目、左から`c`番目のマスを開けます。既に旗が立っている場合には、開けられません。`r`や`c`は`0`から始まることに注意。
- `mineSweeper.status(r, c)`: 上から`r`番目、左から`c`番目のマスの状態（開いている、閉じている、旗が立っている）を返します。
