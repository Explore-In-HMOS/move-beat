import sensor from '@ohos.sensor';
import { ActivityType, Activity } from '../common/model/Activity';

type ActivityChangeCallback = (activity: Activity) => void;

export class ActivityDetector {
  private currentActivity: Activity = new Activity(ActivityType.STATIONARY);
  private listeners: ActivityChangeCallback[] = [];
  private detectionInterval?: number;
  private stepCount: number = 0;
  private lastStepCount: number = 0;
  private isRunning: boolean = false;

  private useMock: boolean;
  private mockTicker?: number;

  constructor(useMock: boolean = true) {
    this.useMock = useMock;
  }

  async start(): Promise<void> {
    if (this.isRunning) {
      return;
    }
    try {
      if (this.useMock) {
        this.startMock();
      } else {
        await this.initializeSensors();
        this.startPeriodicDetection();
        this.detectActivity();
      }
      this.isRunning = true;
      console.info('ActivityDetector started');
    } catch (error) {
      console.error('ActivityDetector start failed, fallback to mock:', error);
      this.startMock();
      this.isRunning = true;
    }
  }

  stop(): void {
    if (!this.isRunning) {
      return;
    }
    this.stopSensors();
    if (this.detectionInterval !== undefined) {
      clearInterval(this.detectionInterval);
      this.detectionInterval = undefined;
    }
    if (this.mockTicker !== undefined) {
      clearInterval(this.mockTicker);
      this.mockTicker = undefined;
    }
    this.isRunning = false;
    console.info('ActivityDetector stopped');
  }

  private async initializeSensors(): Promise<void> {
    try {
      sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
        this.stepCount = data.steps;
      }, { interval: 1000000000 });
    } catch (error) {
      console.error('Pedometer init failed:', error);
      throw new Error(String(error));
    }
  }

  private stopSensors(): void {
    try {
      sensor.off(sensor.SensorId.PEDOMETER);
    } catch (error) {
      console.error('Pedometer stop failed:', error);
    }
  }

  private startPeriodicDetection(): void {
    this.detectionInterval = setInterval((): void => {
      this.detectActivity();
    }, 60000);
  }

  private detectActivity(): void {
    const stepsDelta: number = this.stepCount - this.lastStepCount;
    this.lastStepCount = this.stepCount;

    const stepsPerMinute: number = stepsDelta;
    const newType: ActivityType = this.classifyActivity(stepsPerMinute);

    if (newType !== this.currentActivity.type) {
      this.currentActivity = new Activity(newType);
      this.notifyListeners(this.currentActivity);
      console.info(`[ActivityDetector] change -> ${newType} spm=${stepsPerMinute}`);
    }
  }

  private classifyActivity(spm: number): ActivityType {
    if (spm < 10) {
      return ActivityType.STATIONARY;
    }
    if (spm < 100) {
      return ActivityType.WALKING;
    }
    return ActivityType.RUNNING;
  }

  private startMock(): void {
    const seq: ActivityType[] = [ActivityType.WALKING, ActivityType.RUNNING, ActivityType.WALKING];
    let i: number = 0;

    this.currentActivity = new Activity(seq[i]);
    this.notifyListeners(this.currentActivity);
    console.info(`[ActivityDetector(Mock)] immediate -> ${seq[i]}`);
    i = (i + 1) % seq.length;

    this.mockTicker = setInterval((): void => {
      const next: ActivityType = seq[i];
      i = (i + 1) % seq.length;
      if (next !== this.currentActivity.type) {
        this.currentActivity = new Activity(next);
        this.notifyListeners(this.currentActivity);
        console.info(`[ActivityDetector(Mock)] -> ${next}`);
      }
    }, 10000);
  }

  getCurrentActivity(): Activity {
    return this.currentActivity;
  }

  onActivityChange(cb: ActivityChangeCallback): void {
    this.listeners.push(cb);
  }

  removeActivityChangeListener(cb: ActivityChangeCallback): void {
    const next: ActivityChangeCallback[] = [];
    for (let i = 0; i < this.listeners.length; i++) {
      if (this.listeners[i] !== cb) {
        next.push(this.listeners[i]);
      }
    }
    this.listeners = next;
  }

  private notifyListeners(activity: Activity): void {
    for (let i = 0; i < this.listeners.length; i++) {
      this.listeners[i](activity);
    }
  }
}