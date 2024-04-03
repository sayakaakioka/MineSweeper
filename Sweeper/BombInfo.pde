import java.util.Arrays;

/**
 * 爆弾の有無や周囲8マスの爆弾の数の表現用。
 */
public enum BombInfo {
  TRAPPED(-1),
    NONE(0),
    ONE(1),
    TWO(2),
    THREE(3),
    FOUR(4),
    FIVE(5),
    SIX(6),
    SEVEN(7),
    EIGHT(8),
    UNKNOWN(9);

  private final int id;

  private BombInfo(final int id) {
    this.id = id;
  }

  /*
   * 整数値でidを返す。
   */
  public int id() {
    return this.id;
  }

  /*
   * コード値からの逆引き
   */
   public static BombInfo getById(final int id){
     for(BombInfo info: BombInfo.values()){
       if(info.id() == id){
         return info;
       }
     }
     
     return null;
   }
}
