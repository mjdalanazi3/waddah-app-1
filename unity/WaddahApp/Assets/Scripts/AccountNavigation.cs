using UnityEngine;

public class AuthUIController : MonoBehaviour
{
    [Header("Main Panels")]
    public GameObject loginPanel;
    public GameObject signUpPanel;

    [Header("Sub Panels")]
    public GameObject resetPasswordPanel;

    void Start()
    {
        ShowLogin(); // default page
    }

    // ===== Main Navigation =====
    public void ShowLogin()
    {
        loginPanel.SetActive(true);
        signUpPanel.SetActive(false);
        CloseReset(); // always close reset when returning
    }

    public void ShowSignUp()
    {
        loginPanel.SetActive(false);
        signUpPanel.SetActive(true);
    }

    // ===== Reset Subpanel =====
    public void OpenReset()
    {
        resetPasswordPanel.SetActive(true);
    }

    public void CloseReset()
    {
        resetPasswordPanel.SetActive(false);
    }
}
