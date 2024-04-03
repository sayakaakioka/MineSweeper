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
   * 指定したマスが最後にクリックしたマスならばtrueを返す
   */
   public boolean isLastClicked(int r, int c){
     if (r+1<1 || r+1>status.length-2) {
      throw new IllegalArgumentException("isLastClicked(): 第一引数の値が範囲外です。");
    }

    if (c+1<1 || c+1>status[0].length-2) {
      throw new IllegalArgumentException("isLastClicked(): 第二引数の値が範囲外です。");
    }
    
     if(r+1 == lastClickedR && c+1 == lastClickedC){
       return true;
     }
     return false;
   }

  /**
   * 指定したマスに旗が立っているかどうかを返す。
   */
  public boolean isMarked(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      throw new IllegalArgumentException("isMarked(): 第一引数の値が範囲外です。");
    }

    if (c+1<1 || c+1>status[0].length-2) {
      throw new IllegalArgumentException("isMarked(): 第二引数の値が範囲外です。");
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
      throw new IllegalArgumentException("isOpen(): 第一引数の値が範囲外です。");
    }

    if (c+1<1 || c+1>status[0].length-2) {
      throw new IllegalArgumentException("isOpen(): 第二引数の値が範囲外です。");
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
   * 指定したマスに旗を立てる。
   */
  public void mark(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      throw new IllegalArgumentException("mark(): 第一引数の値が範囲外です。");
    }

    if (c+1<1 || c+1>status[0].length-2) {
      throw new IllegalArgumentException("mark(): 第二引数の値が範囲外です。");
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
   * 指定したマスの爆弾情報を返す
   */
  public BombInfo neighbors(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      throw new IllegalArgumentException("neighbors(): 第一引数の値が範囲外です。");
    }

    if (c+1<1 || c+1>status[0].length-2) {
      throw new IllegalArgumentException("neighbors(): 第二引数の値が範囲外です。");
    }
    
    if(status[r+1][c+1] == Status.OPENED){
      return neighbors[r+1][c+1];
    }
    
    return BombInfo.UNKNOWN;
  }

  /**
   * 指定したマスを開ける。
   * 開けたマスが、周囲8マスが爆弾なしの場合には、これらも開ける。
   */
  public void open(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      throw new IllegalArgumentException("open(): 第一引数の値が範囲外です。");
    }

    if (c+1<1 || c+1>status[0].length-2) {
      throw new IllegalArgumentException("open(): 第二引数の値が範囲外です。");
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
      gameOver = true;
      
      // 全てのマスを開ける
      for(int i=1;  i<status.length-1; i++){
        for(int j=1; j<status[0].length-1; j++){
          status[i][j] = Status.OPENED;
        }
      }
      return;
    }

    // 周囲に開けるべきマスがあれば開ける。
    openAvailable(r+1, c+1);
  }

  /**
   * 指定されたマスの状態を返す
   */
  public Status status(int r, int c) {
    if (r+1<1 || r+1>status.length-2) {
      throw new IllegalArgumentException("status(): 第一引数の値が範囲外です。");
    }

    if (c+1<1 || c+1>status[0].length-2) {
      throw new IllegalArgumentException("status(): 第二引数の値が範囲外です。");
    }
    
    return status[r+1][c+1];
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
  private void openCell(int r, int c) {
    if (status[r][c] == Status.OPENED) {
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
