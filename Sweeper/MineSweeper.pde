/** //<>//
 * マインスイーパーを動かすための諸々を提供。
 */

class MineSweeper {
  // 爆弾の数
  private final int bombs;
  
  // 盤面のマスの数
  private final int rows;
  private final int columns;

  // 最初のクリックかどうか（初回で爆弾を回避するため）
  private boolean firstTime;
  
  // ゲームオーバーかどうか
  private boolean gameOver;
  
  // 最後にクリックしたマスの情報
  private int lastClickedR;
  private int lastClickedC;
  
  // 開けるべき残りのマスの数
  private int counterOpenLeft;
  
  // 旗が立っているマスの数
  private int counterMarked;

  // マスの状態（開いている、閉じているなど）
  private Status[][] status;
  
  // 周囲8マスの爆弾の数
  private BombInfo[][] neighbors;

  /**
   * コンストラクタ
   */
  MineSweeper(int rows, int columns, int bombs) {
    this.bombs = bombs;
    this.rows = rows;
    this.columns = columns;

    // そのセルが開いているか、旗が立っているか、開いていないか。
    // if文を減らすために外側に1周分余計に用意。
    status = new Status[rows+2][columns+2];

    // 周囲8マス分の爆弾の数。サイズについてはstatusと同様。
    // 爆弾の配置は最初のクリック後に実施。
    neighbors = new BombInfo[rows+2][columns+2];

  // 全てを爆弾なし、伏せられた状態で開始
    for (int i=0; i<status.length; i++) {
      for (int j=0; j<status[0].length; j++) {
        status[i][j] = Status.CLOSED;
        neighbors[i][j] = BombInfo.NONE;
      }
    }

    // 一番最初のクリックは爆弾を当てないため。
    firstTime = true;

    // ゲームオーバーかどうかを記録する変数を初期化。
    gameOver = false;

    // 残りの開けるべきマスの数をセット。
    counterOpenLeft = rows*columns-bombs;

    // 旗を立てた数を記録する変数を初期化。
    counterMarked = 0;
  }

  /**
   * ゲームクリア済みかどうかを返す
   */
  public boolean isGameCleared() {
    return counterOpenLeft == 0;
  }

  /**
   * ゲームオーバーしているかどうかを返す
   */
  public boolean isGameOver() {
    return gameOver;
  }

  /**
   * 指定したマスが最後にクリックしたマスならばtrueを返す
   */
   public boolean isLastClicked(int r, int c){
    validateCell("isLastClicked()", r, c);
    return toInnerRow(r) == lastClickedR && toInnerCol(c) == lastClickedC;
   }

  /**
   * 指定したマスに旗が立っているかどうかを返す。
   */
  public boolean isMarked(int r, int c) {
    validateCell("isMarked()", r, c);
    return status[toInnerRow(r)][toInnerCol(c)] == Status.MARKED;
  }

  /**
   * 指定されたマスが開いているかどうかを返す。
   */
  public boolean isOpen(int r, int c) {
    validateCell("isOpen()", r, c);
    return status[toInnerRow(r)][toInnerCol(c)] == Status.OPENED;
  }

  /**
   * 残っている空マスの数を返す。
   */
  public int leftOpen() {
    return counterOpenLeft;
  }

  /**
   * 指定したマスに旗を立てる。
   */
  public void mark(int r, int c) {
    validateCell("mark()", r, c);

    int innerR = toInnerRow(r);
    int innerC = toInnerCol(c);

    if (status[innerR][innerC] != Status.MARKED) {
      status[innerR][innerC] = Status.MARKED;
      counterMarked++;
    } else {
      status[innerR][innerC] = Status.CLOSED;
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
   * 指定したマスの爆弾情報を返す
   */
  public BombInfo neighbors(int r, int c) {
    validateCell("neighbors()", r, c);

    int innerR = toInnerRow(r);
    int innerC = toInnerCol(c);
    
    if (status[innerR][innerC] == Status.OPENED) {
      return neighbors[innerR][innerC];
    }
    
    return BombInfo.UNKNOWN;
  }

  /**
   * 指定したマスを開ける。
   * 開けたマスが、周囲8マスが爆弾なしの場合には、これらも開ける。
   */
  public void openCell(int r, int c) {
    validateCell("openCell()", r, c);
    int innerR = toInnerRow(r);
    int innerC = toInnerCol(c);

    // 初回クリックの場合には、このマスを避けて爆弾を配置する。
    if (firstTime) {
      initializeBoardOnFirstOpen(innerR, innerC);
    }

    // 旗が立っているマスは開けない。
    if (status[innerR][innerC] == Status.MARKED) {
      return;
    }

    // 爆弾があるマスを開けたらゲームオーバー。
    if (neighbors[innerR][innerC] == BombInfo.TRAPPED) {
      lastClickedR = innerR;
      lastClickedC = innerC;
      gameOver = true;
      revealAllCells();
      return;
    }

    // 周囲に開けるべきマスがあれば開ける。
    openAvailable(innerR, innerC);
  }

  /**
   * 指定されたマスの状態を返す
   */
  public Status status(int r, int c) {
    validateCell("status()", r, c);
    return status[toInnerRow(r)][toInnerCol(c)];
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

    openInnerCell(r, c);
    if (neighbors[r][c].id()>0) {
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
  private void openInnerCell(int r, int c) {
    if (status[r][c] == Status.OPENED) {
      return;
    }

    status[r][c] = Status.OPENED;
    counterOpenLeft--;
  }

  // メソッドの引数として受け取る座標が盤面内かどうかを確認する。
  private void validateCell(String methodName, int r, int c) {
    if (r < 0 || r >= rows) {
      throw new IllegalArgumentException(methodName + ": 第一引数の値が範囲外です。");
    }

    if (c < 0 || c >= columns) {
      throw new IllegalArgumentException(methodName + ": 第二引数の値が範囲外です。");
    }
  }

  // 番兵付き配列で扱う内部座標に変換する。
  private int toInnerRow(int r) {
    return r + 1;
  }

  // 番兵付き配列で扱う内部座標に変換する。
  private int toInnerCol(int c) {
    return c + 1;
  }

  // 最初のオープン時に盤面を初期化する。
  private void initializeBoardOnFirstOpen(int r, int c) {
    placeBombs(r, c);
    initNeighbors();
    firstTime = false;
  }

  // ゲームオーバー時に全てのマスを開く。
  private void revealAllCells() {
    for (int i=1; i<status.length-1; i++) {
      for (int j=1; j<status[0].length-1; j++) {
        status[i][j] = Status.OPENED;
      }
    }
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
        if (randomX != r || randomY != c) {
          neighbors[randomX][randomY] = BombInfo.TRAPPED;
          counter++;
        }
      }
    }
  }
}
