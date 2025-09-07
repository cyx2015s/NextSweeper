import { TileData } from "../models/ClassicMineSweeper"

function makeTextColor(number: number): string {
  switch (number) {
    case 1:
      return '#0000FF'; // 蓝色
    case 2:
      return '#008200'; // 绿色
    case 3:
      return '#FF0000'; // 红色
    case 4:
      return '#000084'; // 深蓝色
    case 5:
      return '#840000'; // 棕色
    case 6:
      return '#008284'; // 青色
    case 7:
      return '#000000'; // 黑色
    case 8:
      return '#808080'; // 灰色
    default:
      return '#000000'; // 默认黑色
  }
}

function makeText(tileData: TileData): string {
  if (tileData.flagged && !tileData.revealed) {
    return '🚩';
  } else if (!tileData.revealed) {
    return '';
  } else if (tileData.mine) {
    return '💣';
  } else if (tileData.number > 0) {
    return tileData.number.toString();
  } else {
    return '';
  }
}

function makeBackgroundColor(revealed: boolean): string {
  return revealed ? '#AAAAAA' : '#1177EE';
}

@ComponentV2
export struct Tile {
  @Param @Require tileData: TileData;

  build() {
    if (this.tileData == undefined) {
      Text()
        .width("64px")
        .height("64px")
    } else {
      Text(makeText(this.tileData))
        .fontWeight(FontWeight.Bold)
        .fontColor(makeTextColor(this.tileData.number))
        .fontSize("40px")
        .backgroundColor(makeBackgroundColor(this.tileData.revealed))
        .borderWidth("1px")
        .width("64px")
        .height("64px")
        .textAlign(TextAlign.Center)
    }
  }
}