using FlutterUnityIntegration;
using UnityEngine.InputSystem;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.EventSystems;

public class Game1Manager : MonoBehaviour
{
    // ─────────────────────────────────────────────
    //  AR
    // ─────────────────────────────────────────────
    [Header("AR Components")]
    public ARRaycastManager raycastManager;
    public ARPlaneManager planeManager;

    // ─────────────────────────────────────────────
    //  Part 1 – Station Line
    // ─────────────────────────────────────────────
    [Header("Part 1 – Station Line")]
    public GameObject stationLineParent;
    public GameObject[] stationNodes;
    public int correctStationIndex;

    // ─────────────────────────────────────────────
    //  Part 2 – Tracks & Train
    // ─────────────────────────────────────────────
    [Header("Part 2 – Tracks & Train")]
    public GameObject redTrack;
    public GameObject blueTrack;
    public GameObject orangeTrack;
    public GameObject train;
    public int correctTrackIndex;
    public float trainSlideSpeed = 1.5f;

    // ─────────────────────────────────────────────
    //  Map Boards
    // ─────────────────────────────────────────────
    [Header("Map Boards")]
    public GameObject mapBoard1;                              
    public GameObject mapBoard2;                       
    public Vector3 mapOffsetFromTracks = new Vector3(1.5f, 0f, 0f);

    // ─────────────────────────────────────────────
    //  UI
    // ─────────────────────────────────────────────
    [Header("UI")]
    public TextMeshProUGUI part1QuestionText;
    public TextMeshProUGUI part2QuestionText;
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
    private GameObject[] _tracks;
    private Vector3 _trainTargetPos;
    private bool _trainMoving = false;
    private GraphicRaycaster _graphicRaycaster;
    private EventSystem _eventSystem;

    // ─────────────────────────────────────────────
    //  Init
    // ─────────────────────────────────────────────
    void Start()
    {
        _graphicRaycaster = FindObjectOfType<GraphicRaycaster>();
        _eventSystem = FindObjectOfType<EventSystem>();
        Debug.Log($"✅ GraphicRaycaster found: {_graphicRaycaster != null}");

        _audioSource = GetComponent<AudioSource>();
        if (_audioSource == null)
            _audioSource = gameObject.AddComponent<AudioSource>();

        _tracks = new GameObject[] { redTrack, blueTrack, orangeTrack };

        // Hide Part 2 objects
        if (redTrack != null) redTrack.SetActive(false);
        if (blueTrack != null) blueTrack.SetActive(false);
        if (orangeTrack != null) orangeTrack.SetActive(false);
        if (train != null) train.SetActive(false);
        if (mapBoard2 != null) mapBoard2.SetActive(false);   

        // Show Part 1 objects
        if (stationLineParent != null) stationLineParent.SetActive(true);
        if (mapBoard1 != null) mapBoard1.SetActive(true);    

        // Hide feedback icons
        if (feedbackIconCorrect != null) feedbackIconCorrect.SetActive(false);
        if (feedbackIconWrong != null) feedbackIconWrong.SetActive(false);

        if (part1QuestionText != null) part1QuestionText.gameObject.SetActive(true);
        if (part2QuestionText != null) part2QuestionText.gameObject.SetActive(false);

        Debug.Log("✅ Game1Manager initialized");
    }

    // ─────────────────────────────────────────────
    //  Update
    // ─────────────────────────────────────────────
    void Update()
    {
        if (_trainMoving)
        {
            train.transform.position = Vector3.MoveTowards(
                train.transform.position,
                _trainTargetPos,
                trainSlideSpeed * Time.deltaTime);

            if (Vector3.Distance(train.transform.position, _trainTargetPos) < 0.01f)
                _trainMoving = false;

            return;
        }

        if (_answerLocked) return;

        if (Keyboard.current != null && Keyboard.current.spaceKey.wasPressedThisFrame)
        {
            if (_currentPart == GamePart.Part1)
                HandleStationTap(correctStationIndex);
            else if (_currentPart == GamePart.Part2)
                HandleTrackTap(correctTrackIndex);
            return;
        }

        // Touch input
        if (Touchscreen.current == null) return;

        foreach (var touch in Touchscreen.current.touches)
        {
            if (touch.phase.ReadValue() == UnityEngine.InputSystem.TouchPhase.Began)
            {
                Vector2 pos = touch.position.ReadValue();
                Debug.Log($"👆 Touch detected at: {pos}");
                TrySelectObject(pos);
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

        Debug.Log($"🎯 Raycasting from screen pos: {screenPos}");

        if (!Physics.Raycast(ray, out hit, 20f))
        {
            Debug.Log("❌ Raycast hit nothing");
            return;
        }

        Debug.Log($"✅ Raycast hit: {hit.collider.gameObject.name}");

        GameObject tapped = hit.collider.gameObject;

        if (_currentPart == GamePart.Part1)
        {
            for (int i = 0; i < stationNodes.Length; i++)
            {
                if (stationNodes[i] == null) continue;
                if (tapped == stationNodes[i] ||
                    tapped.transform.IsChildOf(stationNodes[i].transform))
                {
                    Debug.Log($"🚉 Station tapped: {i}");
                    HandleStationTap(i);
                    return;
                }
            }
            Debug.Log("⚠️ Tapped object not a station node");
        }
        else if (_currentPart == GamePart.Part2)
        {
            for (int i = 0; i < _tracks.Length; i++)
            {
                if (_tracks[i] == null) continue;
                if (tapped == _tracks[i] ||
                    tapped.transform.IsChildOf(_tracks[i].transform))
                {
                    Debug.Log($"🚆 Track tapped: {i}");
                    HandleTrackTap(i);
                    return;
                }
            }
            Debug.Log("⚠️ Tapped object not a track");
        }
    }

    // ─────────────────────────────────────────────
    //  Part 1 – Station Tap
    // ─────────────────────────────────────────────
    void HandleStationTap(int index)
    {
        Debug.Log($"HandleStationTap: {index}, correct: {correctStationIndex}");
        if (index == correctStationIndex)
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
    //  Part 2 – Track Tap
    // ─────────────────────────────────────────────
    void HandleTrackTap(int index)
    {
        Debug.Log($"HandleTrackTap: {index}, correct: {correctTrackIndex}");
        if (index == correctTrackIndex)
        {
            ShowFeedback(true);
            _answerLocked = true;

            _trainTargetPos = _tracks[correctTrackIndex].transform.position;
            _trainTargetPos.y = train.transform.position.y;
            _trainMoving = true;

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

        // Hide Part 1 objects
        if (stationLineParent != null) stationLineParent.SetActive(false);
        if (mapBoard1 != null) mapBoard1.SetActive(false);   // hide Part 1 map
        if (feedbackIconCorrect != null) feedbackIconCorrect.SetActive(false);

        // Show Part 2 objects
        if (redTrack != null) redTrack.SetActive(true);
        if (blueTrack != null) blueTrack.SetActive(true);
        if (orangeTrack != null) orangeTrack.SetActive(true);
        if (train != null) train.SetActive(true);
        if (mapBoard2 != null) mapBoard2.SetActive(true);    // show lapboard in Part 2

        if (part1QuestionText != null) part1QuestionText.gameObject.SetActive(false);
        if (part2QuestionText != null) part2QuestionText.gameObject.SetActive(true);

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

        Debug.Log("🏁 Game complete - sending message to Flutter");
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