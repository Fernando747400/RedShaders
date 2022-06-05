using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ChipBag : MonoBehaviour
{
    [Header("Events")]

    [SerializeField] private UnityEvent _startAnim;
    public void StartAnim() => _startAnim?.Invoke();

    [SerializeField] private UnityEvent _chipExplosion;
    public void ChipExplosion() => _chipExplosion?.Invoke();

    [SerializeField] private UnityEvent _finishedAnim;
    public void FinishedAnim() => _finishedAnim?.Invoke();
}
