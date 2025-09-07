import { IMineSweeper, ITileData } from "../interfaces/Interfaces";

@ObservedV2
export class TileData implements ITileData {
  @Trace mine: boolean = false;
  @Trace revealed: boolean = false;
  @Trace flagged: boolean = false;
  @Trace number: number = 0;
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
      this.tiles.push({
          mine: false,
          revealed: false,
          flagged: false,
          number: 0
        });
      }
    }
  }

  neighborRule: (x: number, y: number) => [number, number][] = (x: number, y: number) => {
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

  clone(): ClassicMineSweeper {
    let cloned = new ClassicMineSweeper(this.width, this.height, this.mines);
    cloned.status = this.status;
    cloned.tiles = Array.from(this.tiles, (tile: TileData) => {
      return {
        mine: tile.mine,
        revealed: tile.revealed,
        flagged: tile.flagged,
        number: tile.number
      } as TileData;
    });
    return cloned;
  }

  private placeMines(firstClickX: number, firstClickY: number): void {
    const excluded = this.neighborRule(firstClickX, firstClickY);
    excluded.push([firstClickX, firstClickY]);
    const candidates: [number, number][] = Array.from({ length: this.width * this.height },
      (_: undefined, i: number) => [i % this.width, Math.floor(i / this.width)] as [number, number])
      .filter((cur: [number, number]) => !excluded.some((exc: [number, number]) => exc[0] === cur[0] && exc[1] === cur[1]));
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

  reveal(x: number, y: number): ClassicMineSweeper {
    if (this.status === 'lost' || this.status === 'won') {
      return this.clone();
    }
    if (this.status === 'ready') {
      this.placeMines(x, y);
      this.status = 'playing';
    }
    const tile = this.tiles[y * this.width + x];
    if (tile && (tile.revealed || tile.flagged)) {
      return this.clone();
    }

    tile.revealed = true;
    tile.flagged = false;
    this.revealedCount++;

    if (tile.mine) {
      this.status = 'lost';
      return this.clone();
    }

    // Reveal neighboring tiles if the number is 0
    if (tile.number === 0) {
      for (const nbr of this.neighborRule(x, y)) {
        const nx = nbr[0];
        const ny = nbr[1];
        if (0 <= nx && nx < this.width && 0 <= ny && ny < this.height) {
          this.reveal(nx, ny);
        }
      }
    }

    // Check for win condition
    if (this.revealedCount + this.mines === this.width * this.height) {
      this.status = 'won';
    }

    return this.clone();
  }
  flag(x: number, y: number): ClassicMineSweeper {
    if (this.status === 'lost' || this.status === 'won') {
      return this.clone();
    }
    const tile = this.tiles[y * this.width + x];
    if (tile.revealed) {
      return this.clone();
    }

    tile.flagged = !tile.flagged;
    this.flaggedCount += tile.flagged ? 1 : -1;

    return this.clone();
  }

  chord(x: number, y: number): ClassicMineSweeper {
    if (this.status !== 'playing') {
      return this.clone();
    }
    const tile = this.tiles[y * this.width + x];
    if (!tile.revealed || tile.number === 0) {
      return this.clone();
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

    return this.clone();
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