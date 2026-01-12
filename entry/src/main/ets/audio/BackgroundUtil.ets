import { common } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { audioDomain, audioPrefix } from './MediaController';

const TAG = 'BackgroundUtil';

interface LaunchAbilityOptions {
  operationType: number;
  requestCode: number;
  flags: number[];
}

interface Want {
  bundleName: string;
  abilityName: string;
  options?: LaunchAbilityOptions;
}

export class BackgroundUtil {

  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      hilog.error(audioDomain, audioPrefix, `${TAG} startContinuousTask failed: context is undefined`);
      return;
    }

    const want: Want = {
      bundleName: context.abilityInfo.bundleName,
      abilityName: context.abilityInfo.name,
      options: {
        operationType: 0,
        requestCode: 0,
        flags: [1]
      }
    };

    try {
      backgroundTaskManager.startBackgroundRunning(
        context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
        want
      ).then(() => {
        hilog.info(audioDomain, audioPrefix, `${TAG} startBackgroundRunning succeeded`);
      }).catch((error: BusinessError) => {
        hilog.error(audioDomain, audioPrefix, `${TAG} startBackgroundRunning failed: code ${error.code}, message ${error.message}`);
      });
    } catch (error) {
      hilog.error(audioDomain, audioPrefix, `${TAG} startBackgroundRunning failed: ${(error as BusinessError).message}`);
    }
  }

  public static stopContinuousTask(context: common.UIAbilityContext): void {
    try {
      backgroundTaskManager.stopBackgroundRunning(context).then(() => {
        hilog.info(audioDomain, audioPrefix, `${TAG} stopBackgroundRunning succeeded`);
      }).catch((error: BusinessError) => {
        hilog.error(audioDomain, audioPrefix, `${TAG} stopBackgroundRunning failed: code ${error.code}`);
      });
    } catch (error) {
      hilog.error(audioDomain, audioPrefix, `${TAG} stopBackgroundRunning failed: ${(error as BusinessError).message}`);
    }
  }
}