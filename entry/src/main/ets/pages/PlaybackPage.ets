import { MediaController } from '../audio/MediaController';
import { MusicModel } from '../common/model/MusicModel';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ActivityType } from '../common/model/Activity';

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .objectFit(ImageFit.Contain)
}

@Component
export struct PlaybackPage {
  @StorageLink('selectIndex') selectIndex: number = 0;
  @StorageLink('musicList') musicList: MusicModel[] = [];
  @StorageLink('currentTime') currentTime: string = '00:00';
  @StorageLink('isPlay') isPlay: boolean = false;
  @StorageLink('progress') value: number = 0;
  @StorageLink('progressMax') max: number = 0;
  @StorageLink('currentActivity') currentActivity: number = ActivityType.STATIONARY;

  @State cumulativeDegree: number = 0;
  threshold: number = 10;


  private activityEmoji(): string {
    if (this.currentActivity === ActivityType.WALKING) { return '🚶'; }
    if (this.currentActivity === ActivityType.RUNNING) { return '🏃'; }
    return '🧘';
  }

  private activityLabel(): string {
    if (this.currentActivity === ActivityType.WALKING) { return 'Walking'; }
    if (this.currentActivity === ActivityType.RUNNING) { return 'Running'; }
    return 'Stationary';
  }

  build() {
    Column() {
      Column() {
        Text(this.currentTime)
          .fontColor($r('app.color.color_text_secondary'))
          .fontSize(14)

        Text(this.musicList.length > 0 ? this.musicList[this.selectIndex].title : '')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.color_primary_light'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.musicList.length > 0 ? this.musicList[this.selectIndex].artist : '')
          .fontSize(12)
          .fontColor($r('app.color.color_text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(`${this.activityEmoji()} ${this.activityLabel()}`)
            .fontSize(12)
            .fontColor($r('app.color.color_text_primary'))
            .margin(4)
        }
        .padding(6)
        .backgroundColor($r('app.color.color_surface'))
        .borderRadius(12)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .margin(6)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin(6)

      Row() {
        Image($r('app.media.ic_prev'))
          .controlImageBuilder()
          .width(56)
          .height(56)
          .onClick(() => {
            MediaController.getInstance().playPrevious();
          })

        Image(this.isPlay ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
          .controlImageBuilder()
          .width(68)
          .height(68)
          .onClick(() => {
            hilog.error(0xFF00, 'MusicPlay', `toggle play/pause ${this.isPlay}`);
            if (this.isPlay) {
              MediaController.getInstance().pause();
            } else {
              if (MediaController.getInstance().getFirst()) {
                MediaController.getInstance().startByIndex();
              } else {
                MediaController.getInstance().resume();
              }
            }
          })

        Image($r('app.media.ic_next'))
          .controlImageBuilder()
          .width(56)
          .height(56)
          .onClick(() => {
            MediaController.getInstance().playNext();
          })
      }
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .padding(4)
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
      .onDigitalCrown((event: CrownEvent) => {
        event.stopPropagation();
        this.cumulativeDegree += event.degree;
        if (Math.abs(this.cumulativeDegree) >= this.threshold) {
          if (this.cumulativeDegree > 0) {
            MediaController.getInstance().playPrevious();
          } else {
            MediaController.getInstance().playNext();
          }
          this.cumulativeDegree = 0;
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor($r('app.color.color_background'))
  }
}