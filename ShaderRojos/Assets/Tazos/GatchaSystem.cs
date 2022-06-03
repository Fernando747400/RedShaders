using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GatchaSystem : MonoBehaviour
{
    [Header ("Dependencies")]
    [SerializeField] private GameObject[] _tazos = new GameObject[25];
    [SerializeField] private GameObject _chipBag;
    [SerializeField] private GameObject _tazoPosition;
    [SerializeField] private GameObject _chipsParticles;

    [Header("Settings")]
    [SerializeField] private Vector3 _initialPosition;
    [SerializeField] private Vector3 _centerPosition;
    [SerializeField] private Vector3 _finalPosition;
    [SerializeField] private Vector3 _finalTazoPosition;
    [SerializeField] private Vector3 _removeTazoPosition;
    [SerializeField] private Transform _chipsExplosionPosition;

    private Animator _chipAnimator;
    private GameObject _currentTazo;

    private void Start()
    {
        _chipAnimator = _chipBag.GetComponent<Animator>();
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (_currentTazo != null) RemoveTazo();
            InstantiateChipBag();
        }
    }

    public GameObject PickRandomTazo(GameObject[] list)
    {
       return list[Random.Range(0, list.Length)];
    }

    public void InstantiateChipBag()
    {
        _chipBag.transform.position = _initialPosition;
        _chipBag.transform.rotation = Quaternion.Euler(Vector3.zero);
        _chipAnimator.SetTrigger("EmptyState");

        iTween.MoveTo(_chipBag, iTween.Hash("position",_centerPosition,"time", 3f, "oncomplete", "AnimateChipBag", "oncompletetarget", this.gameObject));
    }
   
    public void AnimateChipBag()
    {
        if(_chipAnimator!= null)
        {
        _chipAnimator.SetTrigger("OpenBag");
        }
    }

    public void PickTazo()
    {
        _tazoPosition.transform.position = Vector3.zero;
        _currentTazo = GameObject.Instantiate(PickRandomTazo(_tazos), _tazoPosition.transform);
        AnimateTazo();
    }

    public void AnimateTazo()
    {
        iTween.MoveTo(_currentTazo, iTween.Hash("position", _finalTazoPosition, "time", 2f,"delay", 2.5f, "oncomplete", "RotateTazo", "oncompletetarget", this.gameObject));
    }

    public void RemoveTazo()
    {
        iTween.MoveTo(_currentTazo, iTween.Hash("position", _removeTazoPosition, "time", 1f, "oncomplete", "DeleteTazo", "oncompletetarget", this.gameObject));
    }

    public void DeleteTazo()
    {
        Destroy(_currentTazo.gameObject);
    }


    public void RotateTazo()
    {
        _currentTazo.gameObject.AddComponent<Cube_Rotation>();
        Cube_Rotation currentRotator = _currentTazo.gameObject.GetComponent<Cube_Rotation>();
        currentRotator.Speed = 5;
        currentRotator.xRotation = 0;
        currentRotator.yRotation = 0;
        currentRotator.zRotation = 5;
    }

    public void FinishAnimation()
    {
        GameObject.Instantiate(_chipsParticles, _chipsExplosionPosition);
        iTween.MoveTo(_chipBag,_finalPosition, 4f);
    }

    

}
