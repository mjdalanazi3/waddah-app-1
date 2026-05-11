using UnityEngine;
using UnityEngine.SceneManagement;

public class FlutterBridge : MonoBehaviour
{
    void Awake()
    {
        DontDestroyOnLoad(gameObject);
    }

    void Start()
    {
        // No need to send ready message - just load the default scene
        // Flutter will call LoadScene via postMessage
    }

    // Called by Flutter via postMessage
    public void LoadScene(string sceneIndexStr)
    {
        if (int.TryParse(sceneIndexStr, out int index))
        {
            SceneManager.LoadScene(index);
        }
    }
}