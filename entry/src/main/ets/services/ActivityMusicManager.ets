import { ActivityDetector } from './ActivityDetector';
import { Activity, ActivityType } from '../common/model/Activity';
import { MediaController } from '../audio/MediaController';
import { MusicModel } from '../common/model/MusicModel';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export class ActivityMusicManager {
  private static instance: ActivityMusicManager | undefined;
  private detector: ActivityDetector;
  private activityToSongs: Map<ActivityType, MusicModel[]> = new Map<ActivityType, MusicModel[]>();
  private currentActivity: ActivityType = ActivityType.STATIONARY;

  private constructor() {
    this.detector = new ActivityDetector(true);
    const self: ActivityMusicManager = this;
    this.detector.onActivityChange((activity: Activity): void => {
      self.onActivityChange(activity);
    });
  }

  static getInstance(): ActivityMusicManager {
    if (!ActivityMusicManager.instance) {
      ActivityMusicManager.instance = new ActivityMusicManager();
    }
    return ActivityMusicManager.instance;
  }

  start(): void {
    this.detector.start();
  }

  stop(): void {
    this.detector.stop();
  }

  setActivitySongs(activity: ActivityType, songs: MusicModel[]): void {
    this.activityToSongs.set(activity, songs);
  }

  private rebuildActiveIndices(activity: ActivityType): void {
    const allSongs: MusicModel[] | undefined = AppStorage.get<MusicModel[]>('musicList');
    if (allSongs === undefined) {
      AppStorage.setOrCreate('activeIndices', [] as number[]);
      return;
    }

    const allowed: number[] = [];
    const stationary = ActivityType.STATIONARY;
    const walking = ActivityType.WALKING;
    const running = ActivityType.RUNNING;

    for (let i = 0; i < allSongs.length; i++) {
      const tag = allSongs[i].activityTag;
      if (activity === stationary && tag === stationary) {
        allowed.push(i);
      } else if (activity === walking && tag === walking) {
        allowed.push(i);
      } else if (activity === running && tag === running) {
        allowed.push(i);
      }
    }

    AppStorage.setOrCreate('activeIndices', allowed);
  }

  private async generateSecureRandom(max: number): Promise<number> {
    const rand = cryptoFramework.createRandom();
    const len = 4;
    const randomBytes = await rand.generateRandom(len);
    const randomValue = new DataView(randomBytes.data.buffer).getUint32(0, true);
    return randomValue % max;
  }

  private async onActivityChange(activity: Activity): Promise<void> {
    this.currentActivity = activity.type;
    AppStorage.setOrCreate('currentActivity', activity.type);

    this.rebuildActiveIndices(activity.type);

    const allowed: number[] | undefined = AppStorage.get<number[]>('activeIndices');
    const allSongs: MusicModel[] | undefined = AppStorage.get<MusicModel[]>('musicList');
    if (allSongs === undefined || allowed === undefined) {
      return;
    }

    if (allowed.length === 0) {
      return;
    }

    const currentIdx: number | undefined = AppStorage.get<number>('selectIndex');
    let currentAllowed = false;
    if (currentIdx !== undefined) {
      for (let i = 0; i < allowed.length; i++) {
        if (allowed[i] === currentIdx) {
          currentAllowed = true;
          break;
        }
      }
    }

    if (!currentAllowed) {
      const pick: number = await this.generateSecureRandom(allowed.length);
      const nextGlobalIndex: number = allowed[pick];
      MediaController.getInstance().startByIndex(nextGlobalIndex);
    }
  }
}