import { common } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MediaTools } from '../audio/MediaTools';
import { resourceManager } from '@kit.LocalizationKit';
import { audioDomain, audioPrefix, MediaController } from './MediaController';
import { MusicModel } from '../common/model/MusicModel';

// Define interfaces for types
interface LaunchAbilityWant {
  bundleName: string;
  abilityName: string;
  options: LaunchAbilityOptions;
}

interface LaunchAbilityOptions {
  operationType: number;
  requestCode: number;
  flags: number[];
}

export class AVSessionController {
  private context?: common.UIAbilityContext;
  private avSession?: avSession.AVSession;
  private musicList: MusicModel[] = [];
  private musicIndex?: number;
  private mediaController?: MediaController;

  constructor() {
    const list: MusicModel[] | undefined = AppStorage.get('musicList');
    if (list) {
      this.musicList = list;
    }
    this.initAVSession();
  }

  public static getInstance(): AVSessionController {
    let avSessionController: AVSessionController | undefined = AppStorage.get('AVSessionController');
    if (!avSessionController) {
      avSessionController = new AVSessionController();
      AppStorage.setOrCreate('AVSessionController', avSessionController);
    }
    return avSessionController;
  }

  private async initAVSession() {
    this.context = AppStorage.get('context');
    if (!this.context) {
      hilog.info(audioDomain, audioPrefix, `session create failed: context is undefined`);
      return;
    }
    this.mediaController = AppStorage.get('mediaController');
    if (!this.mediaController) {
      hilog.info(audioDomain, audioPrefix, `session create failed: mediaController is undefined`);
      return;
    }
    this.avSession = await avSession.createAVSession(this.context, 'PLAY_AUDIO', 'audio');
    await this.avSession.activate();
    hilog.info(audioDomain, audioPrefix, `session create succeeded: sessionId: ${this.avSession.sessionId}`);
    await this.setAVMetadata();
    this.setLaunchAbility();
    this.setListenerForMesFromController();
  }

  private setLaunchAbility() {
    if (!this.context) {
      hilog.error(audioDomain, audioPrefix, 'setLaunchAbility failed: context is undefined');
      return;
    }

    const want: LaunchAbilityWant = {
      bundleName: this.context.abilityInfo.bundleName,
      abilityName: this.context.abilityInfo.name,
      options: {
        operationType: 2,
        requestCode: 0,
        flags: [1]
      }
    };

    try {
      if (this.avSession) {
        this.avSession.setLaunchAbility(want);
        hilog.info(audioDomain, audioPrefix, 'setLaunchAbility executed successfully');
      }
    } catch (error) {
      hilog.error(audioDomain, audioPrefix, `setLaunchAbility failed: ${error}`);
    }
  }

  public async setAVMetadata() {
    this.musicIndex = AppStorage.get('selectIndex');
    hilog.info(audioDomain, audioPrefix, `current musicIndex is: ${this.musicIndex}`);
    if (this.musicIndex === undefined) {
      this.musicIndex = 0;
    }
    try {
      if (this.context) {
        const mediaImage = await MediaTools.getPixelMapFromResource(
          this.context,
          this.musicList[this.musicIndex].artwork as resourceManager.Resource
        );
        hilog.info(audioDomain, audioPrefix, `getPixelMapFromResource success: ${JSON.stringify(mediaImage)}`);
        const metadata: avSession.AVMetadata = {
          assetId: `${this.musicIndex}`,
          title: this.musicList[this.musicIndex].title,
          artist: this.musicList[this.musicIndex].artist,
          mediaImage: mediaImage,
          duration: this.getDuration()
        };
        if (this.avSession) {
          this.avSession.setAVMetadata(metadata).then(() => {
            hilog.info(audioDomain, audioPrefix, 'SetAVMetadata successfully');
          }).catch((err: BusinessError) => {
            hilog.error(audioDomain, audioPrefix, `SetAVMetadata failed: code: ${err.code}, message: ${err.message}`);
          });
        }
      }
    } catch (error) {
      hilog.error(audioDomain, audioPrefix, `SetAVMetadata try: ${error}`);
    }
  }

  async setListenerForMesFromController() {
    if (!this.avSession) {
      return;
    }
    this.avSession.on('play', this.playCall);
    this.avSession.on('pause', this.pauseCall);
    this.avSession.on('playNext', this.playNextCall);
    this.avSession.on('playPrevious', this.playPreviousCall);
    this.avSession.on('seek', this.seekCall);
  }

  private playCall = () => {
    hilog.info(audioDomain, audioPrefix, 'on play, do play task');
    if (!this.mediaController) {
      hilog.error(audioDomain, audioPrefix, 'mediaController is undefined in playCall');
      return;
    }
    if (this.getFirst()) {
      this.mediaController.startByIndex();
    } else {
      this.mediaController.resume();
    }
  };

  private pauseCall = () => {
    hilog.info(audioDomain, audioPrefix, 'on pause, do pause task');
    if (!this.mediaController) {
      hilog.error(audioDomain, audioPrefix, 'mediaController is undefined in pauseCall');
      return;
    }
    this.mediaController.pause();
  };

  private playNextCall = () => {
    hilog.info(audioDomain, audioPrefix, 'on playNext, do playNext task');
    if (!this.mediaController) {
      hilog.error(audioDomain, audioPrefix, 'mediaController is undefined in playNextCall');
      return;
    }
    this.mediaController.playNext();
  };

  private playPreviousCall = () => {
    hilog.info(audioDomain, audioPrefix, 'on playPrevious, do playPrevious task');
    if (!this.mediaController) {
      hilog.error(audioDomain, audioPrefix, 'mediaController is undefined in playPreviousCall');
      return;
    }
    this.mediaController.playPrevious();
  };

  private seekCall = (curMs: number) => {
    hilog.info(audioDomain, audioPrefix, 'on seek, do seek task');
    if (!this.mediaController) {
      hilog.error(audioDomain, audioPrefix, 'mediaController is undefined in seekCall');
      return;
    }
    this.mediaController.seek(curMs);
  };

  private getFirst(): boolean | undefined {
    if (!this.mediaController) {
      return undefined;
    }
    return this.mediaController.getFirst();
  }

  private getDuration(): number | undefined {
    const duration: number | undefined = AppStorage.get('totalMsTime');
    if (!duration) {
      hilog.error(audioDomain, audioPrefix, 'get duration failed');
      return undefined;
    }
    return duration;
  }

  public setProgressState(ms: number) {
    if (this.avSession) {
      this.avSession.setAVPlaybackState({
        position: {
          elapsedTime: ms,
          updateTime: new Date().getTime()
        }
      }, (err: BusinessError) => {
        if (err) {
          hilog.error(audioDomain, audioPrefix, `SetAVPlaybackState failed: code: ${err.code}, message: ${err.message}`);
        }
      });
    }
  }

  public setPlayState(isPlay: boolean) {
    if (this.avSession) {
      this.avSession.setAVPlaybackState({
        state: isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE
      }, (err: BusinessError) => {
        if (err) {
          hilog.error(audioDomain, audioPrefix, `SetAVPlaybackState failed: code: ${err.code}, message: ${err.message}`);
        } else {
          hilog.info(audioDomain, audioPrefix, 'SetAVPlaybackState executed successfully');
        }
      });
    }
  }

  async unregisterSessionListener() {
    if (!this.avSession) {
      return;
    }
    this.avSession.off('play');
    this.avSession.off('pause');
    this.avSession.off('playNext');
    this.avSession.off('playPrevious');
    this.avSession.off('seek');
  }
}