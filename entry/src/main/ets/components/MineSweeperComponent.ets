import { IMineSweeper } from "../interfaces/Interfaces";
import { ClassicMineSweeper } from "../models/ClassicMineSweeper";
import { Tile } from "./TileComponent";

function range(n: number): Array<number> {
  return Array.from({ length: n }, (_: undefined, i: number) => i);
}


@ComponentV2
export struct MineSweeperComponent {
  // Component code here
  @Param @Require gameModel: IMineSweeper;
  @Event onTileClick: (x: number, y: number) => void;
  @Event onTileMouse: (x: number, y: number, e: MouseEvent) => void;

  build() {
    Column() {
      ForEach(range(this.gameModel.height), (y: number) => {
        Row() {
          ForEach(range(this.gameModel.width), (x: number) => {
            Tile({
              tileData: this.gameModel.tiles[y * this.gameModel.width + x],
            }).onMouse((e: MouseEvent) => {
              this.onTileMouse(x, y, e);
            }).onClick(() => {
              this.onTileClick(x, y);
            });
          });
        };
      });
    };
  }
}