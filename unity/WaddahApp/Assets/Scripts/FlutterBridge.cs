using UnityEngine;
using UnityEngine.SceneManagement;
using FlutterUnityIntegration;
using System.Collections;

public class FlutterBridge : MonoBehaviour
{
    void Awake()
    {
        Debug.Log("🔥 FlutterBridge Awake called!");
        DontDestroyOnLoad(gameObject);
    }

    void Start()
    {
        Debug.Log("🔥 FlutterBridge Start called!");
        StartCoroutine(SendReadyAfterDelay());
    }

    IEnumerator SendReadyAfterDelay()
    {
        yield return new WaitForSeconds(1f);
        Debug.Log("🔥 Sending unityReady to Flutter");
UnityMessageManager.Instance.SendMessageToFlutter("UnityReady");
    }

    public void LoadScene(string sceneIndexStr)
    {
        Debug.Log($"🔥 LoadScene called: {sceneIndexStr}");
        if (int.TryParse(sceneIndexStr, out int index))
        {
            SceneManager.LoadScene(index);
        }
    }
}