using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class ARSessionFix : MonoBehaviour
{
    private ARSession arSession;

    void Start()
    {
        arSession = GetComponent<ARSession>();
        StartCoroutine(StartARSession());
    }

    private System.Collections.IEnumerator StartARSession()
    {
        // Wait for Unity to fully initialize in embedded mode
        yield return new WaitForSeconds(1.5f);
        
        if (arSession != null)
        {
            arSession.enabled = false;
            yield return new WaitForSeconds(0.5f);
            arSession.enabled = true;
            Debug.Log("✅ AR Session restarted");
        }
    }
}