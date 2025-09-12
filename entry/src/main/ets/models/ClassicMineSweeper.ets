import { IMineSweeper, ITileData } from "../interfaces/Interfaces";

@ObservedV2
export class TileData implements ITileData {
  @Trace mine: boolean = false;
  @Trace revealed: boolean = false;
  @Trace flagged: boolean = false;
  @Trace number: number = 0;

  constructor(mine: boolean, revealed: boolean, flagged: boolean, number: number) {
    this.mine = mine;
    this.revealed = revealed;
    this.flagged = flagged;
    this.number = number;
  }
}

@ObservedV2
export class ClassicMineSweeper implements IMineSweeper {
  @Trace width: number;
  @Trace height: number;
  @Trace mines: number;
  @Trace tiles: TileData[];
  @Trace status: 'ready' | 'playing' | 'won' | 'lost';
  @Trace revealedCount: number = 0;
  @Trace flaggedCount: number = 0;

  constructor(width: number, height: number, mines: number) {
    this.width = width;
    this.height = height;
    this.mines = mines;
    this.tiles = [];
    this.status = 'ready';

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        this.tiles.push(new TileData(
          false,
          false,
          false,
          0
        ));
      }
    }
  }

  neighborRule(x: number, y: number): [number, number][] {
    const neighbors: [number, number][] = [];
    for (let dy = -1; dy <= 1; dy++) {
      for (let dx = -1; dx <= 1; dx++) {
        if (dx === 0 && dy === 0) {
          continue;
        }
        const nx = x + dx;
        const ny = y + dy;
        neighbors.push([nx, ny]);
      }
    }
    return neighbors;
  };

  private placeMines(firstClickX: number, firstClickY: number): void {
    const excluded = this.neighborRule(firstClickX, firstClickY);
    excluded.push([firstClickX, firstClickY]);
    const candidates: [number, number][] = Array.from({ length: this.width * this.height },
      (_: undefined, i: number) => [i % this.width, Math.floor(i / this.width)] as [number, number])
      .filter((cur: [number, number]) => !excluded.some((exc: [number, number]) => exc[0] === cur[0] &&
        exc[1] === cur[1]));
    for (let i = 0; i < this.mines; i++) {
      const idx = Math.floor(Math.random() * candidates.length);
      const mine_pos = candidates.splice(idx, 1)[0];
      const mx = mine_pos[0];
      const my = mine_pos[1];
      this.tiles[my * this.width + mx].mine = true;
    }
    for (let y = 0; y < this.height; y++) {
      for (let x = 0; x < this.width; x++) {
        let count = 0;
        for (const nbr of this.neighborRule(x, y)) {
          const nx = nbr[0];
          const ny = nbr[1];
          if (nx >= 0 && nx < this.width && ny >= 0 && ny < this.height) {
            if (this.tiles[ny * this.width + nx].mine) {
              count++;
            }
          }
        }
        this.tiles[y * this.width + x].number = count;
      }
    }
  }

  internalReveal(x: number, y: number): void {
    if (this.status === 'lost' || this.status === 'won') {
      return;
    }
    if (this.status === 'ready') {
      this.placeMines(x, y);
      this.status = 'playing';
    }
    if (x < 0 || x >= this.width || y < 0 || y >= this.height) {
      return;
    }
    const tile = this.tiles[y * this.width + x];
    if (tile == undefined) {
      return;
    }
    if (tile.revealed) {
      return;
    }

    tile.revealed = true;
    this.revealedCount++;

    if (tile.mine) {
      this.status = 'lost';
      return;
    }

    if (tile.number === 0) {
      for (const nbr of this.neighborRule(x, y)) {
        const nx = nbr[0];
        const ny = nbr[1];
        this.internalReveal(nx, ny);
      }
    }

  }

  reveal(x: number, y: number): void {
    const tile = this.tiles[y * this.width + x];
    if (tile == undefined || tile.flagged) {
      return;
    }
    this.internalReveal(x, y);
    // Check for win condition
    if (this.revealedCount + this.mines === this.width * this.height) {
      this.status = 'won';
    }
    console.log(`${this.revealedCount} tiles revealed.`);
    return;
  }

  flag(x: number, y: number): void {
    if (this.status === 'lost' || this.status === 'won') {
      return;
    }
    const tile = this.tiles[y * this.width + x];
    if (tile.revealed) {
      return;
    }

    tile.flagged = !tile.flagged;
    this.flaggedCount += tile.flagged ? 1 : -1;
  }

  chord(x: number, y: number): void {
    if (this.status !== 'playing') {
      return;
    }
    const tile = this.tiles[y * this.width + x];
    if (!tile.revealed || tile.number === 0) {
      return;
    }

    const flaggedNeighbors = this.neighborRule(x, y).filter((nbr: [number, number]) => {
      const nx = nbr[0];
      const ny = nbr[1];
      return nx >= 0 && nx < this.width && ny >= 0 && ny < this.height && this.tiles[ny * this.width + nx].flagged;
    }).length;

    if (flaggedNeighbors === tile.number) {
      for (const nbr of this.neighborRule(x, y)) {
        const nx = nbr[0];
        const ny = nbr[1];
        if (nx >= 0 && nx < this.width && ny >= 0 && ny < this.height) {
          this.reveal(nx, ny);
        }
      }
    }
  }

  toString(): string {
    let ret: string = "";
    for (let y = 0; y < this.height; y++) {
      for (let x = 0; x < this.width; x++) {
        const tile = this.tiles[y * this.width + x];
        if (tile.revealed) {
          if (tile.mine) {
            ret += "💣 ";
          } else if (tile.number > 0) {
            ret += tile.number + " ";
          } else {
            ret += "  ";
          }
        } else if (tile.flagged) {
          ret += "🚩 ";
        } else {
          ret += "■ ";
        }
      }
      ret += "\n";
    }
    return ret;
  }
}