using UnityEngine;
using UnityEngine.UI;

#if UNITY_ANDROID
using UnityEngine.Android;
#endif

public class CameraPopupManager : MonoBehaviour
{
    [Header("Popup Root (overlay panel)")]
    [SerializeField] private GameObject popupPanel; // dark overlay root

    [Header("Preview UI")]
    [SerializeField] private GameObject previewPanel; // parent panel for preview (optional)
    [SerializeField] private RawImage previewRawImage; // RawImage to show feed
    [SerializeField] private AspectRatioFitter aspectFitter; // optional but recommended

    private WebCamTexture camTex;

    void Awake()
    {
        if (popupPanel != null) popupPanel.SetActive(false);
        if (previewPanel != null) previewPanel.SetActive(false);
    }

    // Button #1: main camera button
    public void OnCameraButtonClicked()
    {
        if (popupPanel == null) return;

        popupPanel.SetActive(true);
        popupPanel.transform.SetAsLastSibling();
    }

    // Button #2: Allow
    public void OnAllowClicked()
    {
        ClosePopup();

#if UNITY_ANDROID
        // On Android this requests permission; preview will only work on device/emulator with a camera.
        if (!Permission.HasUserAuthorizedPermission(Permission.Camera))
        {
            Permission.RequestUserPermission(Permission.Camera);
            // For Android you would wait and then start preview if granted.
            // For supervisor demo on Windows, we start preview directly below (Editor/Desktop).
        }
#endif

        // Desktop/Editor demo: start webcam preview immediately
        StartCameraPreview();
    }

    // Button #3: Deny
    public void OnDenyClicked()
    {
        ClosePopup();
    }

    public void OnClosePreviewClicked() // optional close button on preview
    {
        StopCameraPreview();
    }

    void ClosePopup()
    {
        if (popupPanel != null) popupPanel.SetActive(false);
    }

    void StartCameraPreview()
    {
        if (previewRawImage == null)
        {
            Debug.LogError("previewRawImage not assigned.");
            return;
        }

        // Force it visible
        previewRawImage.gameObject.SetActive(true);
        if (previewPanel != null) previewPanel.SetActive(true);

        if (WebCamTexture.devices == null || WebCamTexture.devices.Length == 0)
        {
            Debug.LogError("No webcam devices found on this machine.");
            return;
        }

        string deviceName = WebCamTexture.devices[0].name;
        camTex = new WebCamTexture(deviceName, 1280, 720, 30);

        previewRawImage.texture = camTex;
        camTex.Play();
    }

    void StopCameraPreview()
    {
        if (camTex != null)
        {
            if (camTex.isPlaying) camTex.Stop();
            Destroy(camTex);
            camTex = null;
        }

        if (previewPanel != null) previewPanel.SetActive(false);

        Debug.Log("Camera preview stopped.");
    }
}