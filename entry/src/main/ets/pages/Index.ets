import { MediaController } from '../audio/MediaController'
import { MusicModel } from '../common/model/MusicModel'
import MainViewModel from '../viewmodel/MainViewModel'
import { PlaybackPage } from './PlaybackPage'
import { ActivityMusicManager } from '../services/ActivityMusicManager'
import { ActivityType } from '../common/model/Activity'
import { TagSongsPageBuilder } from './TagSongsPage'

@Entry
@Component
struct Index {
  private viewModel: MainViewModel = new MainViewModel()
  musicData: MusicModel[] = []
  pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.musicData = this.viewModel.getMusicList()
    AppStorage.setOrCreate('musicList', this.musicData)
    AppStorage.setOrCreate('PathStack', this.pathStack)

    MediaController.getInstance()

    const activityManager: ActivityMusicManager = ActivityMusicManager.getInstance()
    const walkingSongs: MusicModel[] = []
    const runningSongs: MusicModel[] = []
    const stationarySongs: MusicModel[] = []
    for (let s of this.musicData) {
      if (s.activityTag === ActivityType.WALKING) {
        walkingSongs.push(s)
      }
      else if (s.activityTag === ActivityType.RUNNING) {
        runningSongs.push(s)
      }
      else {
        stationarySongs.push(s)
      }
    }
    activityManager.setActivitySongs(ActivityType.WALKING, walkingSongs)
    activityManager.setActivitySongs(ActivityType.RUNNING, runningSongs)
    activityManager.setActivitySongs(ActivityType.STATIONARY, stationarySongs)
    activityManager.start()
  }

  aboutToDisappear(): void {
    MediaController.getInstance().release()
    ActivityMusicManager.getInstance().stop()
  }

  private openTags(): void {
    this.pathStack.pushPath({ name: 'TagSongsPage' })
  }

  @Builder
  pageMap(name: string) {
    if (name === 'TagSongsPage') {
      TagSongsPageBuilder()
    } else {
      Column() {}
    }
  }

  build() {
    Navigation(this.pathStack) {
      Stack() {
        Column() {
          Row() {
            PlaybackPage().layoutWeight(1)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.color_background'))
        .padding(12)

        Button('🏷')
          .fontSize(18)
          .width(44).height(44)
          .borderRadius(22)
          .backgroundColor($r('app.color.color_primary'))
          .fontColor($r('app.color.color_text_primary'))
          .onClick(() => this.openTags())
          .align(Alignment.Center)
          .margin({ right: 12 })
          .hitTestBehavior(HitTestMode.Block)
      }
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
    .navDestination(this.pageMap)
  }
}