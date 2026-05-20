using FlutterUnityIntegration;
using UnityEngine.InputSystem;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;

public class Game3Manager : MonoBehaviour
{
    [Header("Part 1 – Characters")]
    public GameObject metroEmployee;
    public GameObject policeman;
    public GameObject doctor;

    [Header("Part 2 – Objects")]
    public GameObject metroBench;
    public GameObject metroDoor;
    public GameObject waddah;

    [Header("UI")]
    public TextMeshProUGUI part1QuestionText;
    public TextMeshProUGUI waddahSpeechText;
    public GameObject feedbackIconCorrect;
    public GameObject feedbackIconWrong;

    [Header("Audio")]
    public AudioClip correctSound;
    public AudioClip wrongSound;
    private AudioSource _audioSource;

    private enum GamePart { Part1, Part2, Done }
    private GamePart _currentPart = GamePart.Part1;
    private bool _answerLocked = false;

    void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        if (_audioSource == null)
            _audioSource = gameObject.AddComponent<AudioSource>();

        if (metroBench) metroBench.SetActive(false);
        if (metroDoor) metroDoor.SetActive(false);
        if (waddah) waddah.SetActive(false);

        if (metroEmployee) metroEmployee.SetActive(true);
        if (policeman) policeman.SetActive(true);
        if (doctor) doctor.SetActive(true);

        if (feedbackIconCorrect) feedbackIconCorrect.SetActive(false);
        if (feedbackIconWrong) feedbackIconWrong.SetActive(false);

        if (part1QuestionText) part1QuestionText.gameObject.SetActive(true);
        if (waddahSpeechText) waddahSpeechText.gameObject.SetActive(false);

        Debug.Log("✅ Game2Manager initialized");
    }

    void Update()
    {
        if (_answerLocked) return;

        if (Keyboard.current != null && Keyboard.current.spaceKey.wasPressedThisFrame)
        {
            if (_currentPart == GamePart.Part1)
                HandlePart1Tap(metroEmployee);
            else if (_currentPart == GamePart.Part2)
                HandlePart2Tap(metroBench);
            return;
        }

        if (Touchscreen.current == null) return;

        foreach (var touch in Touchscreen.current.touches)
        {
            if (touch.phase.ReadValue() == UnityEngine.InputSystem.TouchPhase.Began)
            {
                Vector2 pos = touch.position.ReadValue();
                Debug.Log($"👆 Touch at: {pos}");
                TrySelectObject(pos);
                break;
            }
        }
    }

    void TrySelectObject(Vector2 screenPos)
    {
        if (Camera.main == null)
        {
            Debug.Log("❌ Camera.main is null!");
            return;
        }

        Ray ray = Camera.main.ScreenPointToRay(screenPos);
        RaycastHit[] hits = Physics.RaycastAll(ray, 100f);

        Debug.Log($"🎯 RaycastAll found {hits.Length} hits");

        foreach (var hit in hits)
            Debug.Log($"✅ Hit: {hit.collider.gameObject.name}");

        if (hits.Length == 0) return;

        System.Array.Sort(hits, (a, b) => a.distance.CompareTo(b.distance));
        GameObject tapped = hits[0].collider.gameObject;

        if (_currentPart == GamePart.Part1)
        {
            if (metroEmployee && (tapped == metroEmployee || tapped.transform.IsChildOf(metroEmployee.transform)))
            {
                Debug.Log("👤 MetroEmployee tapped");
                HandlePart1Tap(metroEmployee);
            }
            else if (policeman && (tapped == policeman || tapped.transform.IsChildOf(policeman.transform)))
            {
                Debug.Log("👮 Policeman tapped");
                HandlePart1Tap(policeman);
            }
            else if (doctor && (tapped == doctor || tapped.transform.IsChildOf(doctor.transform)))
            {
                Debug.Log("👨‍⚕️ Doctor tapped");
                HandlePart1Tap(doctor);
            }
            else
            {
                Debug.Log($"⚠️ Hit {tapped.name} but not a character");
            }
        }
        else if (_currentPart == GamePart.Part2)
        {
            if (metroBench && (tapped == metroBench || tapped.transform.IsChildOf(metroBench.transform)))
            {
                Debug.Log("🪑 MetroBench tapped");
                HandlePart2Tap(metroBench);
            }
            else if (metroDoor && (tapped == metroDoor || tapped.transform.IsChildOf(metroDoor.transform)))
            {
                Debug.Log("🚪 MetroDoor tapped");
                HandlePart2Tap(metroDoor);
            }
            else
            {
                Debug.Log($"⚠️ Hit {tapped.name} but not a part2 object");
            }
        }
    }

    void HandlePart1Tap(GameObject tapped)
    {
        Debug.Log($"📢 HandlePart1Tap: {tapped.name}");
        if (tapped == metroEmployee)
        {
            ShowFeedback(true);
            _answerLocked = true;
            StartCoroutine(TransitionToPart2());
        }
        else
        {
            ShowFeedback(false);
        }
    }

    void HandlePart2Tap(GameObject tapped)
    {
        Debug.Log($"📢 HandlePart2Tap: {tapped.name}");
        if (tapped == metroBench)
        {
            ShowFeedback(true);
            _answerLocked = true;
            StartCoroutine(FinishGame());
        }
        else
        {
            ShowFeedback(false);
        }
    }

    IEnumerator TransitionToPart2()
    {
        yield return new WaitForSeconds(1.5f);

        if (metroEmployee) metroEmployee.SetActive(false);
        if (policeman) policeman.SetActive(false);
        if (doctor) doctor.SetActive(false);
        if (feedbackIconCorrect) feedbackIconCorrect.SetActive(false);

        if (metroBench) metroBench.SetActive(true);
        if (metroDoor) metroDoor.SetActive(true);
        if (waddah) waddah.SetActive(true);

        if (part1QuestionText) part1QuestionText.gameObject.SetActive(false);
        if (waddahSpeechText) waddahSpeechText.gameObject.SetActive(true);

        _currentPart = GamePart.Part2;
        _answerLocked = false;

        Debug.Log("✅ Transitioned to Part 2");
    }

    IEnumerator FinishGame()
    {
        yield return new WaitForSeconds(3f);
        if (feedbackIconCorrect) feedbackIconCorrect.SetActive(false);
        if (waddahSpeechText) waddahSpeechText.gameObject.SetActive(false);
        _currentPart = GamePart.Done;
        Debug.Log("🏁 Game2 complete!");
        UnityMessageManager.Instance.SendMessageToFlutter("gameComplete");
    }

    void ShowFeedback(bool correct)
    {
        Debug.Log($"📢 ShowFeedback: {correct}");
        if (feedbackIconCorrect) feedbackIconCorrect.SetActive(correct);
        if (feedbackIconWrong) feedbackIconWrong.SetActive(!correct);

        if (correct && correctSound != null)
            _audioSource.PlayOneShot(correctSound);
        else if (!correct && wrongSound != null)
            _audioSource.PlayOneShot(wrongSound);

        if (!correct)
            StartCoroutine(HideWrongFeedback());
    }

    IEnumerator HideWrongFeedback()
    {
        yield return new WaitForSeconds(1f);
        if (feedbackIconWrong) feedbackIconWrong.SetActive(false);
    }
}