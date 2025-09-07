import { MineSweeperComponent } from "../components/MineSweeperComponent";

@Entry
@ComponentV2
struct Index {
  build() {
    RelativeContainer() {
      MineSweeperComponent();
    }
    .height('100%')
    .width('100%')
  }

  onDidBuild(): void {
    console.log("Rebuild: Index");
  }
}