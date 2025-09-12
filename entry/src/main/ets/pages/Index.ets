import { MineSweeperComponent } from "../components/MineSweeperComponent";
import { IMineSweeper } from "../interfaces/Interfaces";
import { ClassicMineSweeper } from "../models/ClassicMineSweeper";

@Entry
@ComponentV2
struct Index {
  @Local gameModel: IMineSweeper = new ClassicMineSweeper(9, 9, 10);
  ttc: TextTimerController = new TextTimerController();
  @Local editingWidth: number = 9;
  @Local editingHeight: number = 9;
  @Local editingMines: number = 10;

  build() {
    SideBarContainer(SideBarContainerType.AUTO) {
      Column() {
        Text("设置").fontSize("48px").alignSelf(ItemAlign.Start)
        Blank().height("96px")
        Divider().vertical(false)
        Text("参数设置").fontSize("36px").alignSelf(ItemAlign.Start).margin("4px")
        Row() {
          Text("宽度").alignSelf(ItemAlign.Start).width("50%")
          Text(this.editingWidth.toString()).textAlign(TextAlign.End).alignSelf(ItemAlign.End).width("50%")
        }.padding("16px")

        Slider({
          value: $$this.editingWidth,
          min: 8,
          max: 30,
          step: 1,
          style: SliderStyle.InSet
        })
        Row() {
          Text("高度").alignSelf(ItemAlign.Start).width("50%")
          Text(this.editingHeight.toString()).textAlign(TextAlign.End).alignSelf(ItemAlign.End).width("50%")
        }.padding("16px")

        Slider({
          value: $$this.editingHeight,
          min: 8,
          max: 24,
          step: 1,
          style: SliderStyle.InSet
        })
        Row() {
          Text("雷数").alignSelf(ItemAlign.Start).width("50%")
          Text(this.editingMines.toString()).textAlign(TextAlign.End).alignSelf(ItemAlign.End).width("50%")
        }.padding("16px")

        Slider({
          value: $$this.editingMines,
          min: 1,
          max: this.editingWidth * this.editingHeight - 25,
          step: 1,
          style: SliderStyle.InSet
        })
        Button("确定").onClick(() => {
          this.gameModel = new ClassicMineSweeper(this.editingWidth, this.editingHeight, this.editingMines);
          this.ttc.reset();
        }).margin({ top: 16 })
      }.width("100%")
      .height("100%")
      .backgroundColor(0xEEEEEE)
      .padding("32px")

      RelativeContainer() {
        Scroll() {
          MineSweeperComponent({
            gameModel: this.gameModel,
            onTileClick: (x: number, y: number): void => {
              if (this.gameModel.status == 'ready') {
                this.ttc.start();
              }
              this.gameModel.reveal(x, y);
              if (this.gameModel.status != 'playing') {
                this.ttc.pause();
              }
            },
            onTileMouse: (x: number, y: number, e: MouseEvent): void => {
              if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
                this.gameModel.flag(x, y);
              }
              if (e.button == MouseButton.Middle && e.action == MouseAction.Press) {
                this.gameModel.chord(x, y);
              }
              if (this.gameModel.status != 'playing') {
                this.ttc.pause();
              }
            }
          })
        }.alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .width("100%")
        .height("100%")
        .scrollable(ScrollDirection.Horizontal)

        Column() {
          Text(`旗子数/雷数: ${this.gameModel.flaggedCount} / ${this.gameModel.mines}`)
          Text(`棋盘大小: ${this.gameModel.width} x ${this.gameModel.height}`)
          TextTimer({ controller: this.ttc })
        }
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          start: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .alignItems(HorizontalAlign.Start)
        .borderRadius("32px")
        .padding("16px")
        .backgroundColor(0xaaeeeeee)
      }
      .height('100%')
      .width('100%')
      .padding("16px")
    }
  }
}