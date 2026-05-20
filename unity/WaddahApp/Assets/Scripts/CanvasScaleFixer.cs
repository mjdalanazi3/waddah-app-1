using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// Fixes the DialogCanvas to use Screen Space - Camera mode at runtime.
/// Vuforia's video background rendering covers Screen Space - Overlay canvases,
/// so we must use Screen Space - Camera mode instead.
/// Attach this to the DialogCanvas GameObject.
/// </summary>
public class CanvasScaleFixer : MonoBehaviour
{
    public bool useWorldSpaceInAR = true;

    void Awake()
    {
        Canvas canvas = GetComponent<Canvas>();
        if (canvas == null)
        {
            GameObject dialogCanvas = GameObject.Find("DialogCanvas");
            if (dialogCanvas != null)
                canvas = dialogCanvas.GetComponent<Canvas>();
        }

        if (canvas == null) return;

        // Fix scale if it's zero
        RectTransform rt = canvas.GetComponent<RectTransform>();
        if (rt != null && rt.localScale == Vector3.zero)
        {
            rt.localScale = Vector3.one;
            Debug.Log("CanvasScaleFixer: Fixed scale from (0,0,0) to (1,1,1)");
        }

        if (useWorldSpaceInAR)
        {
            // If we want World Space, we let other scripts (like VuforiaGameInteraction) handle placement
            canvas.renderMode = RenderMode.WorldSpace;
            Debug.Log("CanvasScaleFixer: Canvas set to World Space (waiting for placement script)");
        }
        else
        {
            // Force Screen Space - Camera mode
            canvas.renderMode = RenderMode.ScreenSpaceCamera;
            canvas.worldCamera = Camera.main;
            canvas.planeDistance = 1f;
            canvas.sortingOrder = 999;
            Debug.Log($"CanvasScaleFixer: Canvas set to Screen Space - Camera (camera={canvas.worldCamera?.name})");
        }
    }
}
