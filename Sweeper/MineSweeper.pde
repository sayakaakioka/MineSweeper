/** //<>//
 * マインスイーパーを動かすための諸々を提供。
 */

class MineSweeper {
  private final int rows;
  private final int columns;
  private final int bombs;
  private final int cellSize;

  private boolean firstTime;
  private boolean gameOver;
  private int lastClickedR;
  private int lastClickedC;
  private int counterOpenLeft;
  private int counterMarked;

  private final color bgColor = color(171, 171, 171);
  private final color fgColor = color(0, 0, 0);

  private Status[][] status;
  private BombInfo[][] neighbors;

  /**
   * コンストラクタ
   */
  MineSweeper(int rows, int columns, int bombs, int cellSize) {
    this.rows = rows;
    this.columns = columns;
    this.bombs = bombs;
    this.cellSize = cellSize;

    // そのセルが開いているか、旗が立っているか、開いていないか。
    // if文を減らすために外側に1周分余計に用意。
    status = new Status[rows+2][columns+2];

    // 周囲8マス分の爆弾の数を保存。サイズについてはstatusと同様。
    // 爆弾の配置は最初のクリック後に実施。
    neighbors = new BombInfo[rows+2][columns+2];

    for (int i=0; i<status.length; i++) {
      for (int j=0; j<status[0].length; j++) {
        status[i][j] = Status.CLOSED;
        neighbors[i][j] = BombInfo.NONE;
      }
    }

    // 一番最初のクリックは爆弾を当てないために用意。
    firstTime = true;

    // ゲームオーバーかどうかを記録する変数を初期化。
    gameOver = false;

    // 残りの開けるべきマスの数をセット。
    counterOpenLeft = rows*columns-bombs;

    // 旗を立てた数を記録する変数を初期化。
    counterMarked = 0;

    // 全てのセルが伏せられた状態でスタート。
    background(bgColor);
    drawLines();
  }

  /**
   * ゲームクリア済みかどうかを返す
   */
  public boolean isGameCleared() {
    if (counterOpenLeft == 0) {
      return true;
    }
    return false;
  }

  /**
   * ゲームオーバーしているかどうかを返す
   */
  public boolean isGameOver() {
    return gameOver;
  }
  
  /**
   * 指定したマスに旗が立っているかどうかを返す。
   */
  public boolean isMarked(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      System.err.println("isFlagged(): 第一引数の値が範囲外です。");
      return false;
    }

    if (c+1<1 || c+1>status[0].length-2) {
      System.err.println("isFlagged(): 第二引数の値が範囲外です。");
      return false;
    }

    if (status[r+1][c+1] == Status.MARKED) {
      return true;
    }
    return false;
  }

  /**
   * 指定されたマスが開いているかどうかを返す。
   */
  public boolean isOpen(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      System.err.println("isOpen(): 第一引数の値が範囲外です。");
      return false;
    }

    if (c+1<1 || c+1>status[0].length-2) {
      System.err.println("isOpen(): 第二引数の値が範囲外です。");
      return false;
    }

    if (status[r+1][c+1] == Status.OPENED) {
      return true;
    }
    return false;
  }

  /**
   * 残っている空マスの数を返す。
   */
  public int leftOpen() {
    return counterOpenLeft;
  }

  /**
   * クリックされたマスに旗を立てる。
   */
  public void mark(int x, int y) {
    markByIndex(y/cellSize, x/cellSize);
  }

  /**
   * 指定したマスに旗を立てる。
   */
  public void markByIndex(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      System.err.println("markByIndex(): 第一引数の値が範囲外です。");
      return;
    }

    if (c+1<1 || c+1>status[0].length-2) {
      System.err.println("markByIndex(): 第二引数の値が範囲外です。");
      return;
    }
    
    if (status[r+1][c+1] != Status.MARKED) {
      status[r+1][c+1] = Status.MARKED;
      counterMarked++;
    } else {
      status[r+1][c+1] = Status.CLOSED;
      counterMarked--;
    }
  }

  /**
   * 立てた旗の数を返す。
   */
  public int marked() {
    return counterMarked;
  }

  /**
   * マウスの座標からクリックされたマスを開ける。
   * 開けたマスが、周囲8マスが爆弾なしの場合には、これらも開ける。
   */
  public void open(int x, int y) {
    openByIndex(y/cellSize, x/cellSize);
  }

  /**
   * 指定したマスを開ける。
   * 開けたマスが、周囲8マスが爆弾なしの場合には、これらも開ける。
   */
  public void openByIndex(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      System.err.println("openByIndex(): 第一引数の値が範囲外です。");
      return;
    }

    if (c+1<1 || c+1>status[0].length-2) {
      System.err.println("openByIndex(): 第二引数の値が範囲外です。");
      return;
    }
    
    // 初回クリックの場合には、このマスを避けて爆弾を配置する。
    if (firstTime) {
      placeBombs(r+1, c+1);
      initNeighbors();
      firstTime = false;
    }

    // 旗が立っているマスは開けない。
    if (status[r+1][c+1] == Status.MARKED) {
      return;
    }

    // 爆弾があるマスを開けたらゲームオーバー。
    if (neighbors[r+1][c+1] == BombInfo.TRAPPED) {
      lastClickedR = r+1;
      lastClickedC = c+1;
      openCell(r+1, c+1);
      gameOver = true;
      return;
    }

    // 周囲に開けるべきマスがあれば開ける。
    openAvailable(r+1, c+1);
  }

  /**
   * ゲームの状況に合わせて描画する。
   */
  public void update() {
    // セルが閉じている状態の色で一旦塗りつぶし。
    background(bgColor);

    // 外周1周分余計に状態を持っているので、そこは描かない。
    for (int i=1; i<status.length-1; i++) {
      for (int j=1; j<status[0].length-1; j++) {
        if (status[i][j] == Status.OPENED) {         // 開いているマス
          drawOpenCell(i, j);
          if (neighbors[i][j] == BombInfo.TRAPPED) { // 爆弾のマス
            drawBomb(i, j);
          } else if (neighbors[i][j].getId()>0) {    // 何もないマス
            drawNumber(i, j);
          }
        } else if (!gameOver && status[i][j] == Status.MARKED) {  // 旗が立っているマス
          drawFlag(i, j);
        } else if (gameOver && neighbors[i][j] == BombInfo.TRAPPED) { // ゲームオーバーで爆弾のマス
          drawBomb(i, j);
        }
      }
    }

    // セルの境界線を描く。
    drawLines();


    if (gameOver) { // ゲームオーバー表示
      fill(255, 0, 0);
      textSize(40);
      text("GAME OVER", width/2, height/2);
    } else if (counterOpenLeft == 0) { // ゲームクリア表示
      textSize(40);
      fill(255, 0, 0);
      text("CLEAR!", width/2, height/2);
    }
  }

  /**
   * 指定したマスに爆弾を描く。
   */
  private void drawBomb(int r, int c) {
    textAlign(CENTER, CENTER);
    fill(255, 0, 0);
    textSize(10);
    text("x", (c-0.5)*cellSize, (r-0.5)*cellSize);
  }

  /**
   * 指定したマスに旗を描く。
   */
  private void drawFlag(int r, int c) {
    textAlign(CENTER, CENTER);
    fill(210, 105, 30);
    textSize(10);
    text("F", (c-0.5)*cellSize, (r-0.5)*cellSize);
  }

  // マスの境界線を描く。
  private void drawLines() {
    stroke(fgColor);

    // 縦方向
    int x = cellSize;
    while (x<width) {
      line(x, 0, x, height);
      x += cellSize;
    }

    // 横方向
    int y = cellSize;
    while (y<height) {
      line(0, y, width, y);
      y += cellSize;
    }
  }

  /**
   * 指定したマスの周囲8マスの爆弾の数を描く。ゼロや爆弾なら描かない。
   */
  private void drawNumber(int r, int c) {
    textAlign(CENTER, CENTER);
    textSize(10);

    switch(neighbors[r][c]) {
    case TRAPPED:
    case NONE:
      return;
    case ONE:
      fill(0, 0, 255);
      break;
    case TWO:
      fill(0, 128, 0);
      break;
    case THREE:
      fill(255, 0, 0);
      break;
    case FOUR:
      fill(35, 59, 108);
      break;
    case FIVE:
      fill(134, 74, 43);
      break;
    case SIX:
      fill(0, 156, 209);
      break;
    case SEVEN:
      fill(0, 0, 0);
      break;
    case EIGHT:
      fill(119, 119, 119);
      break;
    }

    text(neighbors[r][c].getId(), (c-0.5)*cellSize, (r-0.5)*cellSize);
  }

  /**
   * 開いているマスを指定した位置に描く。
   */
  private void drawOpenCell(int r, int c) {
    if (r == lastClickedR && c == lastClickedC) { // 最後にクリックしたマスは特別な色で
      fill(255, 255, 0);
    } else { // 最後にクリックしたマスでなければ普通の色で
      fill(226, 226, 226);
    }
    rect((c-1)*cellSize, (r-1)*cellSize, cellSize, cellSize);
  }

  // 周囲8セルに含まれる爆弾の数を計算する。
  private void initNeighbors() {
    // 外周1周は描画範囲ではないので計算しない
    for (int i=1; i<neighbors.length-1; i++) {
      for (int j=1; j<neighbors[0].length-1; j++) {

        // 爆弾が置かれているセルは何もしない。
        if (neighbors[i][j] == BombInfo.TRAPPED) {
          continue;
        }

        int counter = 0;
        if (neighbors[i-1][j-1] == BombInfo.TRAPPED) {
          counter++;
        }

        if (neighbors[i-1][j] == BombInfo.TRAPPED) {
          counter++;
        }

        if (neighbors[i-1][j+1] == BombInfo.TRAPPED) {
          counter++;
        }

        if (neighbors[i][j-1] == BombInfo.TRAPPED) {
          counter++;
        }

        if (neighbors[i][j+1] == BombInfo.TRAPPED) {
          counter++;
        }

        if (neighbors[i+1][j-1]  == BombInfo.TRAPPED) {
          counter++;
        }

        if (neighbors[i+1][j] == BombInfo.TRAPPED) {
          counter++;
        }

        if (neighbors[i+1][j+1] == BombInfo.TRAPPED) {
          counter++;
        }

        neighbors[i][j] = BombInfo.getById(counter);
      }
    }
  }

  // 指定されたマスの周囲8マスに爆弾がなければ、これらを開ける。
  // この処理を再帰的に行って、開けられるマスを全て開ける。
  private void openAvailable(int r, int c) {
    if (r<1 || r>neighbors.length-2) {
      return;
    }

    if (c<1 || c>neighbors[0].length-2) {
      return;
    }

    if (status[r][c] != Status.CLOSED) {
      return;
    }

    if (neighbors[r][c] == BombInfo.TRAPPED) {
      return;
    }

    openCell(r, c);
    if (neighbors[r][c].getId()>0) {
      return;
    }

    openAvailable(r-1, c-1);
    openAvailable(r-1, c);
    openAvailable(r-1, c+1);
    openAvailable(r, c-1);
    openAvailable(r, c+1);
    openAvailable(r+1, c-1);
    openAvailable(r+1, c);
    openAvailable(r+1, c+1);
  }

  /**
   * 指定したマスをオープンの状態にする。
   */
  private void openCell(int r, int c) {
    if(status[r][c] == Status.OPENED){
      return;
    }
    
    status[r][c] = Status.OPENED;
    counterOpenLeft--;
  }

  // 爆弾を設置する。1番最初にクリックされたマスには置かない。
  private void placeBombs(int r, int c) {
    int counter = 0;

    // 最初に指定した数だけ爆弾を置く
    while (counter<bombs) {
      // 外周には爆弾を置かない
      int randomX = int(random(1, rows+1));
      int randomY = int(random(1, columns+1));

      // まだ爆弾を設置していないマスならば…
      if (neighbors[randomX][randomY] != BombInfo.TRAPPED) {
        // 最初にクリックしたマスは回避
        if (randomX != r && randomY != c) {
          neighbors[randomX][randomY] = BombInfo.TRAPPED;
          counter++;
        }
      }
    }
  }
}
