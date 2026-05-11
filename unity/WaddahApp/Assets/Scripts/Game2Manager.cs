using FlutterUnityIntegration;
using UnityEngine.InputSystem;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;

public class Game2Manager : MonoBehaviour
{
    // ─────────────────────────────────────────────
    //  Part 1 – Identify the Official
    // ─────────────────────────────────────────────
    [Header("Part 1 – Characters")]
    public GameObject metroEmployee;
    public GameObject policeman;
    public GameObject doctor;

    // ─────────────────────────────────────────────
    //  Part 2 – Where to Wait
    // ─────────────────────────────────────────────
    [Header("Part 2 – Objects")]
    public GameObject metroBench;
    public GameObject metroDoor;
    public GameObject waddah;

    // ─────────────────────────────────────────────
    //  UI
    // ─────────────────────────────────────────────
    [Header("UI")]
    public TextMeshProUGUI part1QuestionText;
    public TextMeshProUGUI waddahSpeechText;
    public GameObject feedbackIconCorrect;
    public GameObject feedbackIconWrong;

    // ─────────────────────────────────────────────
    //  Audio
    // ─────────────────────────────────────────────
    [Header("Audio")]
    public AudioClip correctSound;
    public AudioClip wrongSound;
    private AudioSource _audioSource;

    // ─────────────────────────────────────────────
    //  Private State
    // ─────────────────────────────────────────────
    private enum GamePart { Part1, Part2, Done }
    private GamePart _currentPart = GamePart.Part1;
    private bool _answerLocked = false;

    // ─────────────────────────────────────────────
    //  Init
    // ─────────────────────────────────────────────
    void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        if (_audioSource == null)
            _audioSource = gameObject.AddComponent<AudioSource>();

        // Hide Part 2 objects
        if (metroBench != null) metroBench.SetActive(false);
        if (metroDoor != null) metroDoor.SetActive(false);
        if (waddah != null) waddah.SetActive(false);

        // Show Part 1 characters
        if (metroEmployee != null) metroEmployee.SetActive(true);
        if (policeman != null) policeman.SetActive(true);
        if (doctor != null) doctor.SetActive(true);

        // Hide feedback icons
        if (feedbackIconCorrect != null) feedbackIconCorrect.SetActive(false);
        if (feedbackIconWrong != null) feedbackIconWrong.SetActive(false);

        if (part1QuestionText != null) part1QuestionText.gameObject.SetActive(true);
        if (waddahSpeechText != null) waddahSpeechText.gameObject.SetActive(false);

        Debug.Log("✅ Game2Manager initialized");
    }

    // ─────────────────────────────────────────────
    //  Update
    // ─────────────────────────────────────────────
    void Update()
    {
        if (_answerLocked) return;

        // Editor shortcut
        if (Keyboard.current != null && Keyboard.current.spaceKey.wasPressedThisFrame)
        {
            if (_currentPart == GamePart.Part1)
                HandlePart1Tap(metroEmployee);
            else if (_currentPart == GamePart.Part2)
                HandlePart2Tap(metroBench);
            return;
        }

        var activeTouches = UnityEngine.InputSystem.Touchscreen.current?.touches;
        if (activeTouches == null) return;

        foreach (var touch in activeTouches)
        {
            if (touch.phase.ReadValue() == UnityEngine.InputSystem.TouchPhase.Began)
            {
                TrySelectObject(touch.position.ReadValue());
                break;
            }
        }
    }

    // ─────────────────────────────────────────────
    //  Object Selection via Raycast
    // ─────────────────────────────────────────────
    void TrySelectObject(Vector2 screenPos)
    {
        if (Camera.main == null)
        {
            Debug.Log("❌ Camera.main is null!");
            return;
        }

        Ray ray = Camera.main.ScreenPointToRay(screenPos);
        RaycastHit hit;

        Debug.Log($"🎯 Raycast fired at: {screenPos}");

        if (!Physics.Raycast(ray, out hit, 20f))
        {
            Debug.Log("❌ Raycast hit nothing");
            return;
        }

        Debug.Log($"✅ Raycast hit: {hit.collider.gameObject.name}");

        GameObject tapped = hit.collider.gameObject;

        if (_currentPart == GamePart.Part1)
        {
            if (tapped == metroEmployee ||
                tapped.transform.IsChildOf(metroEmployee.transform))
            {
                HandlePart1Tap(metroEmployee);
            }
            else if (tapped == policeman ||
                     tapped.transform.IsChildOf(policeman.transform))
            {
                HandlePart1Tap(policeman);
            }
            else if (tapped == doctor ||
                     tapped.transform.IsChildOf(doctor.transform))
            {
                HandlePart1Tap(doctor);
            }
        }
        else if (_currentPart == GamePart.Part2)
        {
            if (tapped == metroBench ||
                tapped.transform.IsChildOf(metroBench.transform))
            {
                HandlePart2Tap(metroBench);
            }
            else if (tapped == metroDoor ||
                     tapped.transform.IsChildOf(metroDoor.transform))
            {
                HandlePart2Tap(metroDoor);
            }
        }
    }

    // ─────────────────────────────────────────────
    //  Part 1 – Character Tap
    // ─────────────────────────────────────────────
    void HandlePart1Tap(GameObject tapped)
    {
        Debug.Log($"👤 HandlePart1Tap: {tapped.name}");

        if (tapped == metroEmployee)
        {
            ShowFeedback(true);
            _answerLocked = true;
            StartCoroutine(TransitionToPart2());
        }
        else
        {
            ShowFeedback(false);
            _answerLocked = true;
            StartCoroutine(ResetAfterWrong());
        }
    }

    // ─────────────────────────────────────────────
    //  Part 2 – Object Tap
    // ─────────────────────────────────────────────
    void HandlePart2Tap(GameObject tapped)
    {
        Debug.Log($"🪑 HandlePart2Tap: {tapped.name}");

        if (tapped == metroBench)
        {
            ShowFeedback(true);
            _answerLocked = true;
            StartCoroutine(FinishGame());
        }
        else
        {
            ShowFeedback(false);
            _answerLocked = true;
            StartCoroutine(ResetAfterWrong());
        }
    }

    // ─────────────────────────────────────────────
    //  Reset after wrong answer
    // ─────────────────────────────────────────────
    IEnumerator ResetAfterWrong()
    {
        yield return new WaitForSeconds(1f);
        _answerLocked = false;
        Debug.Log("🔓 Answer unlocked — player can try again");
    }

    // ─────────────────────────────────────────────
    //  Transition Part 1 → Part 2
    // ─────────────────────────────────────────────
    IEnumerator TransitionToPart2()
    {
        yield return new WaitForSeconds(1.5f);

        // Hide Part 1
        if (metroEmployee != null) metroEmployee.SetActive(false);
        if (policeman != null) policeman.SetActive(false);
        if (doctor != null) doctor.SetActive(false);
        if (feedbackIconCorrect != null) feedbackIconCorrect.SetActive(false);

        // Show Part 2
        if (metroBench != null) metroBench.SetActive(true);
        if (metroDoor != null) metroDoor.SetActive(true);
        if (waddah != null) waddah.SetActive(true);

        if (part1QuestionText != null) part1QuestionText.gameObject.SetActive(false);
        if (waddahSpeechText != null) waddahSpeechText.gameObject.SetActive(true);

        _currentPart = GamePart.Part2;
        _answerLocked = false;

        Debug.Log("✅ Transitioned to Part 2");
    }

    // ─────────────────────────────────────────────
    //  Finish Game
    // ─────────────────────────────────────────────
    IEnumerator FinishGame()
    {
        yield return new WaitForSeconds(3f);

        if (feedbackIconCorrect != null) feedbackIconCorrect.SetActive(false);
        _currentPart = GamePart.Done;

        Debug.Log("🏁 Game2 complete - sending message to Flutter");
        UnityMessageManager.Instance.SendMessageToFlutter("gameComplete");
    }

    // ─────────────────────────────────────────────
    //  Feedback
    // ─────────────────────────────────────────────
    void ShowFeedback(bool correct)
    {
        Debug.Log($"📢 ShowFeedback: {correct}");

        if (feedbackIconCorrect != null) feedbackIconCorrect.SetActive(correct);
        if (feedbackIconWrong != null) feedbackIconWrong.SetActive(!correct);

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
        if (feedbackIconWrong != null) feedbackIconWrong.SetActive(false);
    }
}