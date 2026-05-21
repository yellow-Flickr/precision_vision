// Central app-wide provider barrel.
// Features expose their providers from their own providers.dart files.


export 'package:precision_vision/settings/providers.dart'
    show
        modelOrchestratorProvider,
        mobileNetDetectorProvider,
        yoloV8DetectorProvider;

export 'package:precision_vision/camera_stream/providers.dart'
    show
        cameraStreamProvider,
        liveDetectionsProvider,
        liveFpsProvider,
        cameraControllerProvider;
