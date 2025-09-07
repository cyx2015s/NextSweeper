import { ClassicMineSweeper } from "../models/ClassicMineSweeper";
import { Tile } from "./TileComponent";

function range(n: number): Array<number> {
  return Array.from({ length: n }, (_: undefined, i: number) => i);
}


@ComponentV2
export struct MineSweeperComponent {
  // Component code here
  @Local gameModel: ClassicMineSweeper = new ClassicMineSweeper(9, 9, 10);
  @Event onTileClick?: (x: number, y: number) => void;
  @Event onTileMouse?: (x: number, y: number, e: MouseEvent) => void;

  build() {
    Column() {
      ForEach(range(this.gameModel.height), (y: number) => {
        Row() {
          ForEach(range(this.gameModel.width), (x: number) => {
            Tile({
              tileData: this.gameModel.tiles[y * this.gameModel.width + x],
            }).onMouse((e: MouseEvent) => {
            //
            }).onClick(() => {
              this.gameModel = this.gameModel.reveal(x, y);
              // console.log(this.gameModel.toString());
            });
          });
        };
      });
    };
  }

  onDidBuild(): void {
    console.log("Rebuild: MineSweeper");
  }

  aboutToAppear(): void {
    this.gameModel.reveal(3,4);
  }
}