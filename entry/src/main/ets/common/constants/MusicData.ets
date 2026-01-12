import { MusicModel } from '../model/MusicModel';

export class MusicData {
  public static readonly MUSIC_LIST: MusicModel[] = [
    {
      id: 1,
      title: 'Dream It Possible',
      artist: 'Delacey',
      artwork: $r('app.media.ic_dream_it'),
      src: 'dream_it_possible_delacey.mp3'
    },
    {
      id: 2,
      title: 'World',
      artist: '张三-你好我好都好',
      artwork: $r('app.media.ic_world'),
      src: 'world.mp3'
    },
    {
      id: 3,
      title: 'Power',
      artist: '不知道你是谁',
      artwork: $r('app.media.ic_power'),
      src: 'power.mp3'
    },
    {
      id: 4,
      title: 'Boisterous',
      artist: '我是小树',
      artwork: $r('app.media.ic_boisterous'),
      src: 'boisterous.mp3'
    }
  ];
}