import { MusicModel } from '../common/model/MusicModel'
import { ActivityType } from '../common/model/Activity'

@Builder
export function TagSongsPageBuilder() {
  TagSongsPage()
}

@Entry
@Component
struct TagSongsPage {
  @State songs: MusicModel[] = []
  private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    const list: MusicModel[] | undefined = AppStorage.get<MusicModel[]>('musicList')
    if (list !== undefined) {
      this.songs = list
    }
  }

  private labels(): string[] {
    return ['None', 'Walking', 'Running', 'Stationary']
  }

  private indexOf(song: MusicModel): number {
    if (song.activityTag === undefined) {
      return 0
    }
    if (song.activityTag === ActivityType.WALKING) {
      return 1
    }
    if (song.activityTag === ActivityType.RUNNING) {
      return 2
    }
    return 3
  }

  private apply(songIdx: number, pickerIdx: number): void {
    if (pickerIdx === 0) {
      this.songs[songIdx].activityTag = undefined
    } else if (pickerIdx === 1) {
      this.songs[songIdx].activityTag = ActivityType.WALKING
    } else if (pickerIdx === 2) {
      this.songs[songIdx].activityTag = ActivityType.RUNNING
    } else {
      this.songs[songIdx].activityTag = ActivityType.STATIONARY
    }
    AppStorage.setOrCreate('musicList', this.songs)
  }

  build() {
    NavDestination() {
      Column() {
        Text('Tag Songs')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin(6)
          .onClick(() => this.pathStack.pop())

        List() {
          ForEach(
            this.songs,
            (song: MusicModel) => {
              ListItem() {
                Column() {
                  Text(song.title)
                    .fontSize(14)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin(4)

                  TextPicker({
                    range: this.labels(),
                    selected: this.indexOf(song)
                  })
                    .onChange((value: string | string[], index: number | number[]) => {
                      const i: number = Array.isArray(index)
                        ? index.length > 0
                          ? index[0]
                          : 0
                        : index;
                      this.apply(song.id, i);
                    })
                    .margin(2)
                }
                .padding(8);
              }
            },
            (song: MusicModel): string => song.id.toString()
          )
        }
        .layoutWeight(1)
      }
      .padding(10)
      .height('100%')
      .width('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}