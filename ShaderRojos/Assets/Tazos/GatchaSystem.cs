using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GatchaSystem : MonoBehaviour
{
    [Header ("Dependencies")]
    [SerializeField] private GameObject[] _tazosArray = new GameObject[1];
    [SerializeField] private GameObject _chipBag;
    [SerializeField] private GameObject _tazoPosition;
    [SerializeField] private GameObject _chipsParticles;

    [Header("UI Dependencies")]
    [SerializeField] private Button _openButton;

    [Header("Random selection")]
    [Header("Settings")]
    [SerializeField] private bool _randomTazoSelection;
    [SerializeField] private float _turningSpeed;

    [Header("Chipbag position vectors")]
    [SerializeField] private Vector3 _initialBagPosition;
    [SerializeField] private Vector3 _centerBagPosition;
    [SerializeField] private Vector3 _finalBagPosition;

    [Header("Tazo position vectors")]
    [SerializeField] private Vector3 _centerTazoPosition;
    [SerializeField] private Vector3 _finalTazoPosition;

    [Header("Chips explosion position")]
    [SerializeField] private Transform _chipsExplosionPosition;

    private Animator _chipAnimator;
    private GameObject _currentPickedTazo;
    private Queue _tazosQueue = new Queue();
    private bool _onCooldown;

    private void Start()
    {
        _chipAnimator = _chipBag.GetComponent<Animator>();
        AddToQueue();
        _onCooldown = false;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space) && !_onCooldown)
        {
            OpenNewBag();
        }
    }

    public void OpenNewBag()
    {
        if (_currentPickedTazo != null) RemoveTazo();
        _openButton.interactable = false;
        _onCooldown = true;
        FirstChipBagAnimation();
    }


    public void FirstChipBagAnimation()
    {
        if(_chipAnimator != null) _chipAnimator.SetTrigger("EmptyState");
        _chipBag.transform.position = _initialBagPosition;
        _chipBag.transform.rotation = Quaternion.Euler(Vector3.zero);

        iTween.MoveTo(_chipBag, iTween.Hash("position",_centerBagPosition,"time", 3f, "oncomplete", "AnimateChipBag", "oncompletetarget", this.gameObject));
    }
   
    public void AnimateChipBag()
    {
        if(_chipAnimator!= null) _chipAnimator.SetTrigger("OpenBag");
    }


    public void PickTazo() //this method is called by the ChipBag animator event. 
    {
        _tazoPosition.transform.position = Vector3.zero;

        if (_randomTazoSelection)
        {
            _currentPickedTazo = GameObject.Instantiate(PickRandomTazo(_tazosArray), _tazoPosition.transform);
        }
        else
        {
            _currentPickedTazo = GameObject.Instantiate(PickNextTazo());
        }
        AnimateTazo();
    }
    public GameObject PickRandomTazo(GameObject[] list)
    {
       return list[Random.Range(0, list.Length)];
    }

    public GameObject PickNextTazo()
    {
        if (_tazosQueue.Count == 0) AddToQueue();
        GameObject temp = (GameObject)_tazosQueue.Peek();
        _tazosQueue.Dequeue();
        return temp;
    }

    public void AnimateTazo()
    {
        iTween.MoveTo(_currentPickedTazo, iTween.Hash("position", _centerTazoPosition, "time", 2f,"delay", 2.5f, "oncomplete", "RotateTazo", "oncompletetarget", this.gameObject));
    }

    public void RemoveTazo()
    {
        iTween.MoveTo(_currentPickedTazo, iTween.Hash("position", _finalTazoPosition, "time", 1f, "oncomplete", "DeleteTazo", "oncompletetarget", this.gameObject));
    }

    public void DeleteTazo()
    {
        Destroy(_currentPickedTazo.gameObject);
    }


    public void RotateTazo()
    {
        _currentPickedTazo.gameObject.AddComponent<Cube_Rotation>();
        Cube_Rotation currentRotator = _currentPickedTazo.gameObject.GetComponent<Cube_Rotation>();
        currentRotator.Speed = _turningSpeed;
        currentRotator.xRotation = 0;
        currentRotator.yRotation = 0;
        currentRotator.zRotation = 5;
        _onCooldown = false;
        _openButton.interactable = true;
    }

    public void FinishAnimation() //This method is called by the ChipBag animator event
    {
        GameObject.Instantiate(_chipsParticles, _chipsExplosionPosition);
        iTween.MoveTo(_chipBag,_finalBagPosition, 4f);
    }

    private void AddToQueue()
    {
        if(_tazosQueue.Count != 0)_tazosQueue.Clear();
        foreach (var tazo in _tazosArray)
        {
            _tazosQueue.Enqueue(tazo);
        }
    }

    public void TogggleRandom()
    {
        _randomTazoSelection = !_randomTazoSelection;
    }
}
