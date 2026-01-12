import { MusicData } from '../common/constants/MusicData';
import { MusicModel } from '../common/model/MusicModel';

export default class MainViewModel {
  public getMusicList(): MusicModel[] {
    return MusicData.MUSIC_LIST;
  }
}