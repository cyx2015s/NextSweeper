export interface ITileData {
  mine: boolean;
  revealed: boolean;
  flagged: boolean;
  number: number;
}

export interface IMineSweeper {
  width: number;
  height: number;
  mines: number;
  tiles: ITileData[];
  status: 'ready' | 'playing' | 'won' | 'lost';
  revealedCount: number;
  flaggedCount: number;

  neighborRule: (x: number, y: number) => [number, number][];
  clone(): IMineSweeper;
  reveal(x: number, y: number): IMineSweeper;
  flag(x: number, y: number): IMineSweeper;
  chord(x: number, y: number): IMineSweeper;
}