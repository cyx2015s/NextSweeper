import { MineSweeperComponent } from "../components/MineSweeperComponent";
import { IMineSweeper } from "../interfaces/interfaces";
import { ClassicMineSweeper } from "../models/ClassicMineSweeper";

@Entry
@ComponentV2
struct Index {
  @Local gameModel: IMineSweeper = new ClassicMineSweeper(9, 9, 10);

  build() {
    RelativeContainer() {
      MineSweeperComponent({
        gameModel: this.gameModel,
        onTileClick: (x: number, y: number): void => {
          this.gameModel = this.gameModel.reveal(x, y);
        },
        onTileMouse: (x: number, y: number, e: MouseEvent): void => {
          console.log(`${x}, ${y}, ${e}`)
        }
      });
    }
    .height('100%')
    .width('100%')
  }

  onDidBuild(): void {
    console.log("Rebuild: Index");
  }
}